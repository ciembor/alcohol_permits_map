require 'geocoding/krakow_msip_address_client'

module Geocoding
  class KrakowMsipAddressGeocoder
    SOURCE = 'krakow_msip'.freeze

    def initialize(client: Geocoding::KrakowMsipAddressClient.new, throttle_seconds: 0.0, select_result: true)
      @client = client
      @throttle_seconds = throttle_seconds
      @select_result = select_result
    end

    def geocode(transformed_location)
      return unless transformed_location.address_kind == 'street_address'
      return if transformed_location.building_number.blank?

      candidates = address_candidates(transformed_location)
      return if candidates.empty?

      existing = existing_result(transformed_location, candidates)
      if existing
        store_source_coordinates(existing)
        return existing
      end

      pending_candidates = candidates.reject { |candidate| result_exists?(transformed_location, candidate) }
      if pending_candidates.empty?
        result = stored_result(transformed_location, candidates)
        store_source_coordinates(result) if result
        return result
      end

      attempts = []
      selected_attempt = nil

      pending_candidates.each do |candidate|
        response = client.search(street: candidate.fetch(:street), number: transformed_location.building_number)
        feature = matching_feature(response, candidate.fetch(:street), transformed_location.building_number)
        attempts << { candidate: candidate, response: response, feature: feature }
        selected_attempt ||= attempts.last if feature
        sleep(throttle_seconds) if throttle_seconds.positive?
        break if selected_attempt
      end

      selected_attempt ||= attempts.first || { candidate: candidates.first, response: empty_response, feature: nil }
      result = create_result(transformed_location, selected_attempt, attempts)
      store_source_coordinates(result)
      select_result(result) if select_result? && result.latitude.present? && result.longitude.present?
      result
    end

    private

    attr_reader :client, :throttle_seconds

    def address_candidates(transformed_location)
      number = transformed_location.building_number
      aliases = transformed_location.same_as.to_s.split('|').filter_map do |street|
        street = street.strip.squeeze(' ')
        next if street.blank?

        {
          strategy: 'address_point',
          street: street,
          number: number,
          query: [street, number, 'Kraków'].join(' ')
        }
      end

      historical = {
        strategy: aliases.any? ? 'historical_address_point' : 'address_point',
        street: transformed_location.address_1.to_s,
        number: number,
        query: [transformed_location.address_1, number, 'Kraków'].compact.join(' ')
      }

      preferred = aliases.presence || [historical]
      fallback = aliases.any? ? [historical] : []

      (preferred + preferred.flat_map { |candidate| without_leading_kind_candidates(candidate) } +
        fallback + fallback.flat_map { |candidate| without_leading_kind_candidates(candidate) })
        .uniq { |candidate| [candidate[:strategy], normalize_street(candidate[:street]), candidate[:query]] }
    end

    def without_leading_kind_candidates(candidate)
      street = without_leading_kind(candidate.fetch(:street))
      return [] if street.blank? || normalize_street(street) == normalize_street(candidate.fetch(:street))

      [
        candidate.merge(
          street: street,
          query: [street, candidate.fetch(:number), 'Kraków'].join(' ')
        )
      ]
    end

    def without_leading_kind(value)
      value
        .to_s
        .sub(/\A(Aleja|Aleje|Osiedle|Plac|Ulica)\s+/i, '')
        .sub(/\A(al\.|os\.|pl\.|ul\.)\s+/i, '')
    end

    def existing_result(transformed_location, candidates)
      GeocodingResult
        .where(
          transformed_location: transformed_location,
          source: SOURCE,
          strategy: candidates.map { |candidate| candidate.fetch(:strategy) },
          query: candidates.map { |candidate| candidate.fetch(:query) }
        )
        .where.not(latitude: nil, longitude: nil)
        .first
    end

    def result_exists?(transformed_location, candidate)
      GeocodingResult.exists?(
        transformed_location: transformed_location,
        source: SOURCE,
        strategy: candidate.fetch(:strategy),
        query: candidate.fetch(:query)
      )
    end

    def stored_result(transformed_location, candidates)
      GeocodingResult.find_by(
        transformed_location: transformed_location,
        source: SOURCE,
        strategy: candidates.map { |candidate| candidate.fetch(:strategy) },
        query: candidates.map { |candidate| candidate.fetch(:query) }
      )
    end

    def matching_feature(response, expected_street, expected_number)
      return unless response[:status] == 200

      features = response.dig(:body, 'features')
      return unless features.is_a?(Array)

      features.find do |feature|
        properties = feature['properties'] || {}
        normalize_street(properties['nazwa_ulicy']) == normalize_street(expected_street) &&
          normalize_number(properties['numer_adresowy']) == normalize_number(expected_number) &&
          krakow_feature?(properties) &&
          feature.dig('geometry', 'coordinates').is_a?(Array)
      end
    end

    def krakow_feature?(properties)
      properties['miejscowosc'].to_s.casecmp('Kraków').zero?
    end

    def normalize_number(value)
      value.to_s.upcase.gsub(/\s+/, '')
    end

    def normalize_street(value)
      ActiveSupport::Inflector
        .transliterate(without_leading_kind(value))
        .downcase
        .gsub(/[.,]/, ' ')
        .gsub(/\s+/, ' ')
        .strip
    end

    def create_result(transformed_location, selected_attempt, attempts)
      candidate = selected_attempt.fetch(:candidate)
      feature = selected_attempt[:feature]
      coordinates = feature&.dig('geometry', 'coordinates')
      properties = feature && feature['properties']

      GeocodingResult.create!(
        transformed_location: transformed_location,
        source: SOURCE,
        strategy: candidate.fetch(:strategy),
        query: candidate.fetch(:query),
        latitude: coordinates && coordinates[1],
        longitude: coordinates && coordinates[0],
        precision: feature && 'address_point/msip_emuia',
        raw_response: {
          attempts: attempts.map do |attempt|
            {
              candidate: attempt.fetch(:candidate),
              status: attempt.fetch(:response)[:status],
              url: attempt.fetch(:response)[:url],
              match: attempt[:feature]&.fetch('properties', nil)
            }
          end,
          selected: properties
        }.to_json
      )
    end

    def empty_response
      { status: nil, url: nil, body: nil }
    end

    def select_result(result)
      result.transaction do
        GeocodingResult.where(transformed_location_id: result.transformed_location_id).update_all(selected: false)
        result.update!(selected: true)
        result.transformed_location.use_geocoding_result!(result)
      end
    end

    def store_source_coordinates(result)
      result.transformed_location.store_geocoder_coordinates!(SOURCE, result.latitude, result.longitude)
    end

    def select_result?
      @select_result
    end
  end
end
