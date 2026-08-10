require 'geocoding/gus_address_client'

module Geocoding
  class GusAddressGeocoder
    SOURCE = 'gus'.freeze
    KRAKOW_COUNTY_TERYT = Geocoding::GusAddressClient::KRAKOW_COUNTY_TERYT

    def initialize(
      client: Geocoding::GusAddressClient.new,
      throttle_seconds: 0.0,
      strategy: 'address_point',
      select_result: true
    )
      @client = client
      @throttle_seconds = throttle_seconds
      @strategy = strategy
      @select_result = select_result
    end

    def geocode(transformed_location)
      query = transformed_location.geocoding_queries.find do |candidate|
        candidate[:strategy] == strategy
      end
      return unless query
      query = query.merge(
        street: query[:street] || transformed_location.address_1,
        number: query[:house_number] || query[:number] || transformed_location.building_number,
        postal_code: query[:postal_code]
      )

      existing = existing_result(transformed_location, query)
      if existing
        store_source_coordinates(existing)
        return existing
      end

      response = client.search(
        query[:query],
        street: query[:street],
        number: query[:number],
        postal_code: query[:postal_code]
      )

      row = first_result(response)
      point = address_point(row)
      matched_point = point if point && acceptable_match?(row, point, query)

      result = create_result(
        transformed_location,
        query,
        response,
        row,
        matched_point
      )
      store_source_coordinates(result)

      if select_result? && matched_point
        select_result(result)
      end

      sleep(throttle_seconds) if throttle_seconds.positive?

      result
    end

    private

    attr_reader :client, :throttle_seconds, :strategy

    def existing_result(transformed_location, query)
      GeocodingResult.find_by(
        transformed_location: transformed_location,
        source: SOURCE,
        strategy: query[:strategy],
        query: query[:query]
      )
    end

    def first_result(response)
      return unless response[:status] == 200
      return unless response[:body].is_a?(Array)

      response[:body].first
    end

    def address_point(row)
      single = row && row['single']
      return unless single.is_a?(Hash)
      return unless krakow_result?(single)

      coordinates =
        single.dig('geometry', 'coordinates') ||
        single.dig('record', 'geometry', 'coordinates')

      return unless coordinates.is_a?(Array) && coordinates.size >= 2

      {
        longitude: coordinates[0].to_f,
        latitude: coordinates[1].to_f,
        street: single['ul_pelna'],
        number: single['pkt_numer'],
        postal_code: single['pkt_kodPocztowy'],
        teryt: result_teryt(single),
        county_teryt: result_county_teryt(single),
        id: single['id']
      }
    end

    def krakow_result?(single)
      county_teryt = result_county_teryt(single)
      return true if county_teryt == KRAKOW_COUNTY_TERYT

      result_teryt(single).to_s.start_with?(KRAKOW_COUNTY_TERYT)
    end

    def result_teryt(single)
      single['teryt'].to_s.presence ||
        single.dig('record', 'properties', 'gm_idteryt').to_s.presence
    end

    def result_county_teryt(single)
      single
        .dig('record', 'properties', 'pow_idteryt')
        .to_s
        .presence
    end

    def acceptable_match?(row, point, query)
      return false unless row

      expected_number = query[:house_number] || query[:number]
      expected_street = query[:street]

      if expected_number.present? &&
          normalize_number(point[:number]) != normalize_number(expected_number)
        return false
      end

      if expected_street.present? &&
          normalize_street(point[:street]) != normalize_street(expected_street)
        return false
      end

      true
    end

    def normalize_number(value)
      value.to_s.upcase.gsub(/\s+/, '')
    end

    def normalize_street(value)
      normalized = value
        .to_s
        .downcase
        .gsub(/[.,]/, ' ')
        .gsub(/\s+/, ' ')
        .strip

      normalized = normalized.sub(
        /\A(?:ulica|ul|aleja|al|plac|pl|osiedle|os)\s+/,
        ''
      ) while normalized.match?(/\A(?:ulica|ul|aleja|al|plac|pl|osiedle|os)\s+/)

      normalized
    end

    def create_result(transformed_location, query, response, row, point)
      GeocodingResult.create!(
        transformed_location: transformed_location,
        source: SOURCE,
        strategy: query[:strategy],
        query: query[:query],
        latitude: point && point[:latitude],
        longitude: point && point[:longitude],
        confidence: row && row['relevance'],
        precision: point && 'address_point',
        raw_response: response.to_json
      )
    end

    def select_result(result)
      result.transaction do
        GeocodingResult
          .where(transformed_location_id: result.transformed_location_id)
          .update_all(selected: false)

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
