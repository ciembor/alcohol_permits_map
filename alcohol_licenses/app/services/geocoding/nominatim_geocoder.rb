require 'json'
require 'geocoding/nominatim_client'

module Geocoding
  class NominatimGeocoder
    SOURCE = 'nominatim'.freeze

    def initialize(client: Geocoding::NominatimClient.new, throttle_seconds: 1.1, strategy: 'address_point', select_result: true)
      @client = client
      @throttle_seconds = throttle_seconds
      @strategy = strategy
      @select_result = select_result
    end

    def geocode(transformed_location)
      query = transformed_location.geocoding_queries.find { |candidate| candidate[:strategy] == strategy }
      return unless query

      existing = existing_result(transformed_location, query)
      if existing
        store_source_coordinates(existing)
        return existing
      end

      response = client.search(query[:query])
      result = create_result(transformed_location, query, response)
      store_source_coordinates(result)
      select_result(result) if select_result? && result.latitude.present? && result.longitude.present?
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

    def create_result(transformed_location, query, response)
      first = first_krakow_result(response)

      GeocodingResult.create!(
        transformed_location: transformed_location,
        source: SOURCE,
        strategy: query[:strategy],
        query: query[:query],
        latitude: first && first['lat'],
        longitude: first && first['lon'],
        confidence: first && first['importance'],
        precision: precision(first),
        raw_response: response.to_json
      )
    end

    def precision(result)
      return unless result

      [result['class'], result['type'], result['addresstype']].compact.join('/')
    end

    def first_krakow_result(response)
      return unless response[:body].is_a?(Array)

      response[:body].find { |result| krakow_result?(result) }
    end

    def krakow_result?(result)
      address = result['address']
      return false unless address.is_a?(Hash)

      address.values_at('city', 'town', 'village', 'municipality').compact.include?('Kraków')
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
