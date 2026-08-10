require 'json'
require 'geocoding/uldk_client'

module Geocoding
  class UldkParcelGeocoder
    SOURCE = 'uldk'.freeze

    CADASTRAL_UNITS = {
      'krowodrza' => '126102_9',
      'nowa_huta' => '126103_9',
      'podgorze' => '126104_9',
      'srodmiescie' => '126105_9'
    }.freeze
    STREET_REGION_HINTS = [
      [/aleja adama mickiewicza/i, 'krowodrza', %w[14]],
      [/bogucianka/i, 'podgorze', %w[5 13 14 21 22 44 56 60 61 64 67 73 74 77 91 108]],
      [/bulwarowa/i, 'nowa_huta', %w[44]],
      [/dajwór/i, 'srodmiescie', %w[12]],
      [/długa/i, 'srodmiescie', %w[8 59 116]],
      [/gramatyka/i, 'krowodrza', %w[4]],
      [/jana brożka/i, 'podgorze', %w[32]],
      [/jarzębiny/i, 'nowa_huta', %w[10]],
      [/józefa wybickiego/i, 'krowodrza', %w[41]],
      [/stefana grota-roweckiego/i, 'podgorze', %w[34]]
    ].freeze

    STREET_UNIT_HINTS = {
      /aleja 29 listopada/i => 'srodmiescie',
      /aleja adama mickiewicza/i => 'krowodrza',
      /aleja gen\.? władysława andersa/i => 'nowa_huta',
      /aleja marszałka ferdinanda focha/i => 'krowodrza',
      /bogucianka/i => 'podgorze',
      /bulwar czerwieński/i => 'srodmiescie',
      /bulwar kurlandzki/i => 'srodmiescie',
      /bulwar inflancki/i => 'srodmiescie',
      /bulwar wołyński/i => 'podgorze',
      /bulwarowa/i => 'nowa_huta',
      /dajwór/i => 'srodmiescie',
      /długa/i => 'srodmiescie',
      /estońska/i => 'podgorze',
      /gramatyka/i => 'krowodrza',
      /henryka i karola czeczów/i => 'podgorze',
      /igołomska/i => 'nowa_huta',
      /jana brożka/i => 'podgorze',
      /jarzębiny/i => 'nowa_huta',
      /józefa wybickiego/i => 'krowodrza',
      /kolna/i => 'podgorze',
      /litewska/i => 'krowodrza',
      /park lotników polskich/i => 'nowa_huta',
      /plac inwalidów/i => 'krowodrza',
      /półłanki/i => 'podgorze',
      /stefana grota-roweckiego/i => 'podgorze',
      /trakt papieski/i => 'podgorze',
      /wojciecha weissa/i => 'krowodrza',
      /zalew nowohucki/i => 'nowa_huta'
    }.freeze

    def initialize(client: Geocoding::UldkClient.new, throttle_seconds: 0.2)
      @client = client
      @throttle_seconds = throttle_seconds
    end

    def geocode(transformed_location)
      return unless transformed_location.geocoding_strategy == 'cadastral_parcel'

      candidates = parcel_id_candidates(transformed_location)
      query = candidates.first || transformed_location.geocoding_address
      return geocode_inferred_region(transformed_location, candidates) if inferred_region_search?(transformed_location, candidates)

      existing = existing_result(transformed_location, query)
      return existing if existing

      result = nil

      candidates.each do |parcel_id|
        response = client.search_parcel(parcel_id)
        parsed = parse_response(response)
        result = create_result(transformed_location, parcel_id, response, parsed)
        store_source_coordinates(result)
        break if result.latitude.present? && result.longitude.present?

        sleep(throttle_seconds) if throttle_seconds.positive?
      end

      result ||= create_result(transformed_location, nil, empty_response(candidates), nil)
      store_source_coordinates(result)
      select_result(result) if result.latitude.present? && result.longitude.present?
      result
    end

    private

    attr_reader :client, :throttle_seconds

    def existing_result(transformed_location, query)
      GeocodingResult.find_by(
        transformed_location: transformed_location,
        source: SOURCE,
        strategy: 'cadastral_parcel',
        query: query
      )
    end

    def parcel_id_candidates(transformed_location)
      parcel_numbers = parcel_number_values(transformed_location.parcel_number)
      return [] if parcel_numbers.empty?

      raw_address = transformed_location.raw_address_2.to_s
      street_region_hint = street_region_hint(transformed_location.address_1)
      district_key = transformed_location.parcel_cadastral_unit || district_key(raw_address) || street_region_hint&.fetch(:unit) || street_unit_hint(transformed_location.address_1)
      region_numbers = parcel_region_values(transformed_location.parcel_region || region_number(raw_address))
      region_numbers = street_region_hint&.fetch(:regions) if district_key.present? && region_numbers.empty?
      region_numbers ||= []
      return [] if district_key.blank? || region_numbers.empty?

      region_numbers.product(parcel_numbers).map do |region_number, parcel_number|
        "#{CADASTRAL_UNITS.fetch(district_key)}.#{region_number.rjust(4, '0')}.#{parcel_number}"
      end
    end

    def parcel_number_values(parcel_number)
      parcel_number.to_s.split('|').map(&:strip).reject(&:blank?).uniq
    end

    def parcel_region_values(parcel_region)
      parcel_region.to_s.split('|').map(&:strip).reject(&:blank?).uniq
    end

    def district_key(raw_address)
      normalized = raw_address.downcase
      return 'srodmiescie' if normalized.match?(/śród|srod/)
      return 'podgorze' if normalized.match?(/podg/)
      return 'nowa_huta' if normalized.match?(/nowa\s*huta|nh/)
      return 'krowodrza' if normalized.match?(/krow/)
    end

    def street_unit_hint(address_1)
      STREET_UNIT_HINTS.each do |pattern, key|
        return key if address_1.to_s.match?(pattern)
      end

      nil
    end

    def street_region_hint(address_1)
      STREET_REGION_HINTS.each do |pattern, unit, regions|
        return { unit: unit, regions: regions } if address_1.to_s.match?(pattern)
      end

      nil
    end

    def region_number(raw_address)
      if raw_address.match(/obr(?:ęb)?\.?\s*(?:nr\.?\s*)?(?:[A-Z]\s*-\s*)?([0-9]{1,4}(?:\s*,\s*[0-9]{1,4})*)/i)
        Regexp.last_match(1)
          .scan(/[0-9]{1,4}/)
          .map { |number| number.to_i.to_s }
          .uniq
          .join('|')
      elsif raw_address.match(/\b[0-9]{1,3}-0*([0-9]{1,4})\b/)
        Regexp.last_match(1)
      end
    end

    def parse_response(response)
      row = response[:body].to_s.lines.map(&:strip).find { |line| line.start_with?('12') && line.include?('|') }
      return unless row

      id, voivodeship, county, commune, region, parcel, geom_wkt, datasource = row.split('|', 8)
      latitude, longitude = centroid(geom_wkt)

      {
        id: id,
        voivodeship: voivodeship,
        county: county,
        commune: commune,
        region: region,
        parcel: parcel,
        geom_wkt: geom_wkt,
        datasource: datasource,
        latitude: latitude,
        longitude: longitude
      }
    end

    def inferred_region_search?(transformed_location, candidates)
      candidates.present? &&
        transformed_location.parcel_region.blank? &&
        region_number(transformed_location.raw_address_2.to_s).blank?
    end

    def geocode_inferred_region(transformed_location, candidates)
      successful_results = []

      candidates.each do |parcel_id|
        result = existing_result(transformed_location, parcel_id)
        unless result
          response = client.search_parcel(parcel_id)
          parsed = parse_response(response)
          result = create_result(transformed_location, parcel_id, response, parsed)
          sleep(throttle_seconds) if throttle_seconds.positive?
        end

        store_source_coordinates(result)
        successful_results << result if result.latitude.present? && result.longitude.present?
      end

      if successful_results.one? && parcel_number_values(transformed_location.parcel_number).one?
        result = successful_results.first
        select_result(result)
        return result
      end

      result = if successful_results.any?
                 ambiguous_result(transformed_location, candidates, successful_results)
               else
                 create_result(transformed_location, nil, empty_response(candidates), nil)
               end
      store_source_coordinates(result)
      result
    end

    def create_result(transformed_location, parcel_id, response, parsed)
      existing = existing_result(transformed_location, parcel_id || transformed_location.geocoding_address)
      return existing if existing

      GeocodingResult.create!(
        transformed_location: transformed_location,
        source: SOURCE,
        strategy: 'cadastral_parcel',
        query: parcel_id || transformed_location.geocoding_address,
        latitude: parsed && parsed[:latitude],
        longitude: parsed && parsed[:longitude],
        precision: parsed && "parcel/#{parsed[:region]}",
        raw_response: { candidates: Array(parcel_id), response: response, parsed: parsed }.to_json
      )
    end

    def ambiguous_result(transformed_location, candidates, successful_results)
      query = "ambiguous: #{transformed_location.geocoding_address}"
      existing = existing_result(transformed_location, query)
      return existing if existing

      GeocodingResult.create!(
        transformed_location: transformed_location,
        source: SOURCE,
        strategy: 'cadastral_parcel',
        query: query,
        precision: 'parcel/ambiguous',
        raw_response: {
          candidates: candidates,
          matched: successful_results.map do |result|
            {
              query: result.query,
              latitude: result.latitude,
              longitude: result.longitude,
              precision: result.precision
            }
          end
        }.to_json
      )
    end

    def empty_response(candidates)
      {
        status: nil,
        body: nil,
        candidates: candidates
      }
    end

    def centroid(geom_wkt)
      return if geom_wkt.blank?

      coordinates = geom_wkt.scan(/(-?\d+(?:\.\d+)?)\s+(-?\d+(?:\.\d+)?)/).map do |lon, lat|
        [lon.to_f, lat.to_f]
      end
      return if coordinates.empty?

      lon = coordinates.sum(&:first) / coordinates.size
      lat = coordinates.sum(&:last) / coordinates.size
      [lat, lon]
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
  end
end
