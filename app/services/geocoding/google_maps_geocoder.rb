require 'json'
require 'geocoding/google_maps_client'
require 'geocoding/location_uncertainty'

module Geocoding
  class GoogleMapsGeocoder
    SOURCE = 'google'.freeze

    def initialize(client: Geocoding::GoogleMapsClient.new, throttle_seconds: 0.1)
      @client = client
      @throttle_seconds = throttle_seconds
    end

    def geocode(transformed_location)
      last_result = nil

      queries_for(transformed_location).each do |query|
        existing = existing_result(transformed_location, query)
        result = existing || geocode_query(transformed_location, query)
        repair_result(result) unless result.latitude.present? && result.longitude.present?
        store_source_coordinates(result)
        last_result = result
        valid_result = stored_result_matches_location?(result, transformed_location)

        if valid_result && result.latitude.present? && result.longitude.present? && improves_location?(transformed_location, result)
          select_result(result)
          return result
        end

        return result if valid_result &&
          result.latitude.present? &&
          result.longitude.present? &&
          google_quality(result) >= selected_quality(transformed_location)
      end

      places_queries_for(transformed_location).each do |query|
        existing = existing_result(transformed_location, places_query_key(query))
        result = existing || geocode_places_query(transformed_location, query)
        store_source_coordinates(result)
        last_result = result
        valid_result = stored_result_matches_location?(result, transformed_location)

        if valid_result && result.latitude.present? && result.longitude.present? && improves_location?(transformed_location, result)
          select_result(result)
          return result
        end

        return result if valid_result &&
          result.latitude.present? &&
          result.longitude.present? &&
          google_quality(result) >= selected_quality(transformed_location)
      end

      last_result
    end

    private

    attr_reader :client, :throttle_seconds

    def geocode_query(transformed_location, query)
      response = client.search(query)
      validate_response!(response)
      sleep(throttle_seconds) if throttle_seconds.positive?
      create_result(transformed_location, query, response)
    end

    def geocode_places_query(transformed_location, query)
      response = client.text_search(query)
      validate_places_response!(response)
      sleep(throttle_seconds) if throttle_seconds.positive?
      create_places_result(transformed_location, query, response)
    end

    def existing_result(transformed_location, query)
      GeocodingResult.find_by(
        transformed_location: transformed_location,
        source: SOURCE,
        strategy: transformed_location.geocoding_strategy,
        query: query
      )
    end

    def queries_for(transformed_location)
      [query_for(transformed_location), street_query_for(transformed_location)].compact.map(&:strip).reject(&:empty?).uniq
    end

    def places_queries_for(transformed_location)
      return [] if transformed_location.address_kind == 'parcel'

      queries_for(transformed_location).map { |query| places_query_text(query) }.uniq
    end

    def query_for(transformed_location)
      return 'Plac Nowy Kleparz Kraków' if nowy_kleparz_marketplace?(transformed_location)

      transformed_location.geocoding_address.to_s.strip
    end

    def street_query_for(transformed_location)
      return unless transformed_location.address_kind == 'street_address'
      return if transformed_location.building_number.to_s.strip.empty?

      "ulica #{transformed_location.geocoding_address}"
    end

    def places_query_key(query)
      "places:text: #{query}"
    end

    def places_query_text(query)
      query.to_s.sub(/\Aulica\s+/i, '').strip
    end

    def nowy_kleparz_marketplace?(transformed_location)
      transformed_location.address_1.to_s.casecmp('Plac Nowy Kleparz').zero? &&
        %w[pavilion landmark].include?(transformed_location.address_kind.to_s)
    end

    def validate_response!(response)
      return unless response[:body].is_a?(Hash)

      status = response[:body]['status']
      return if status == 'OK' || status == 'ZERO_RESULTS'

      message = response[:body]['error_message'].to_s
      message = "Google Maps Geocoding API returned #{status}" if message.empty?
      raise StandardError, message
    end

    def validate_places_response!(response)
      return unless response[:body].is_a?(Hash)
      return unless response[:status].to_i >= 400 || response[:body]['error'].present?

      error = response[:body]['error'] || {}
      message = error['message'].to_s
      message = "Google Places Text Search API returned #{response[:status]}" if message.empty?
      raise StandardError, message
    end

    def create_result(transformed_location, query, response)
      parsed = best_result(response, transformed_location)
      location = parsed && parsed.dig('geometry', 'location')

      GeocodingResult.create!(
        transformed_location: transformed_location,
        source: SOURCE,
        strategy: transformed_location.geocoding_strategy,
        query: query,
        latitude: location && location['lat'],
        longitude: location && location['lng'],
        confidence: confidence(parsed),
        precision: precision(parsed),
        raw_response: response.to_json
      )
    end

    def create_places_result(transformed_location, query, response)
      place = best_place(response, transformed_location)
      location = place && place['location']

      GeocodingResult.create!(
        transformed_location: transformed_location,
        source: SOURCE,
        strategy: transformed_location.geocoding_strategy,
        query: places_query_key(query),
        latitude: location && location['latitude'],
        longitude: location && location['longitude'],
        confidence: place_confidence(place),
        precision: place_precision(place),
        raw_response: response.to_json
      )
    end

    def repair_result(result)
      response = JSON.parse(result.raw_response)
      parsed = best_result({ status: response['status'], body: response['body'] }, result.transformed_location)
      location = parsed && parsed.dig('geometry', 'location')
      return unless location

      result.update!(
        latitude: location['lat'],
        longitude: location['lng'],
        confidence: confidence(parsed),
        precision: precision(parsed)
      )
    rescue JSON::ParserError
      nil
    end

    def stored_result_matches_location?(result, transformed_location)
      return false unless result.latitude.present? && result.longitude.present?
      return true if result.raw_response.blank?

      response = JSON.parse(result.raw_response)
      if result.precision.to_s.start_with?('PLACES/')
        place = Array(response.dig('body', 'places')).find { |item| krakow_place?(item) }
        place && result_matches_location?(place, transformed_location)
      else
        parsed = Array(response.dig('body', 'results')).find { |item| krakow_result?(item) }
        parsed && result_matches_location?(parsed, transformed_location)
      end
    rescue JSON::ParserError, TypeError
      false
    end

    def best_result(response, transformed_location = nil)
      return unless response[:body].is_a?(Hash)

      Array(response[:body]['results']).find do |result|
        krakow_result?(result) && result_matches_location?(result, transformed_location)
      end
    end

    def best_place(response, transformed_location = nil)
      return unless response[:body].is_a?(Hash)

      Array(response[:body]['places']).find do |place|
        krakow_place?(place) && result_matches_location?(place, transformed_location)
      end
    end

    def krakow_result?(result)
      components = Array(result['address_components'])
      component_values = components.flat_map do |component|
        [component['long_name'], component['short_name']]
      end.compact

      krakow_text = component_values.any? do |value|
        value == 'Kraków' ||
          value.start_with?('Kraków-') ||
          value == 'Powiat Kraków'
      end

      krakow_text && coordinates_in_krakow?(google_result_coordinates(result))
    end

    def krakow_place?(place)
      krakow_text = formatted_result_texts(place).any? { |text| normalized_text(text).include?('krakow') } ||
        place_components(place).flat_map { |component| component_names(component) }.compact.any? do |value|
          value == 'Kraków' ||
            value.start_with?('Kraków-') ||
            value == 'Powiat Kraków'
        end

      krakow_text && coordinates_in_krakow?(place_coordinates(place))
    end

    def coordinates_in_krakow?(coordinates)
      return true unless coordinates

      sim_locator.locate(coordinates.fetch(:latitude), coordinates.fetch(:longitude)).present?
    end

    def sim_locator
      @sim_locator ||= Sim::Locator.new
    end

    def google_result_coordinates(result)
      location = result.dig('geometry', 'location')
      return unless location

      {
        latitude: location['lat'],
        longitude: location['lng']
      }
    end

    def place_coordinates(place)
      location = place['location']
      return unless location

      {
        latitude: location['latitude'],
        longitude: location['longitude']
      }
    end

    def result_matches_location?(result, transformed_location)
      return true unless transformed_location

      if transformed_location.address_kind == 'street_address' && transformed_location.building_number.present?
        route_matches?(result, transformed_location.address_1) &&
          street_number_matches?(result, transformed_location.building_number, transformed_location)
      elsif transformed_location.address_kind == 'parcel' && transformed_location.address_1.present?
        route_matches?(result, transformed_location.address_1)
      else
        true
      end
    end

    def route_matches?(result, expected_route)
      expected_tokens = significant_route_tokens(expected_route)
      return true if expected_tokens.empty?

      route_components(result).any? do |route|
        actual_tokens = significant_route_tokens(route)
        next false if actual_tokens.empty?

        missing = expected_tokens - actual_tokens
        missing.empty? || (expected_tokens.size > 2 && missing.size <= 1)
      end || formatted_route_matches?(result, expected_tokens)
    end

    def street_number_matches?(result, expected_number, transformed_location = nil)
      expected = normalized_street_number(expected_number)
      return true if expected.blank?

      street_number_components(result).any? { |number| normalized_street_number(number) == expected } ||
        formatted_result_texts(result).any? { |text| text_contains_street_number?(text, expected) }
    end

    def route_components(result)
      place_components(result).select do |component|
        Array(component['types']).include?('route')
      end.flat_map { |component| component_names(component) }.compact
    end

    def street_number_components(result)
      place_components(result).select do |component|
        Array(component['types']).include?('street_number')
      end.flat_map { |component| component_names(component) }.compact
    end

    def place_components(result)
      Array(result['address_components'] || result['addressComponents'])
    end

    def component_names(component)
      [
        component['long_name'],
        component['short_name'],
        component['longText'],
        component['shortText']
      ]
    end

    def formatted_route_matches?(result, expected_tokens)
      formatted_result_texts(result).any? do |text|
        actual_tokens = significant_route_tokens(text)
        missing = expected_tokens - actual_tokens
        missing.empty? || (expected_tokens.size > 2 && missing.size <= 1)
      end
    end

    def formatted_result_texts(result)
      display_name = result.dig('displayName', 'text') if result.is_a?(Hash)
      [result['formatted_address'], result['formattedAddress'], display_name].compact
    end

    def text_contains_street_number?(text, expected)
      normalized_text(text).upcase.split.any? { |token| normalized_street_number(token) == expected }
    end

    def normalized_route(value)
      normalized_text(value)
        .sub(/\Aal(?:eja)?\s+/, '')
        .sub(/\Aul(?:ica)?\s+/, '')
        .sub(/\Aos(?:iedle)?\s+/, 'osiedle ')
        .sub(/\Apl(?:ac)?\s+/, 'plac ')
        .sub(/\Adr\s+/, 'doktora ')
    end

    def significant_route_tokens(value)
      normalized_route(value)
        .split
        .reject { |token| route_stop_token?(token) }
    end

    def route_stop_token?(token)
      %w[
        aleja al ulica ul osiedle os plac pl
        gen generala marszalka plk pulkownika rtm rotmistrza
        dr doktora sw swietego swieta im imienia
        adama andrzeja bohdana ferdinanda henryka jakuba jerzego joachima
        joanny joanny jozefa juliusza karola ksiecia lucjana stanislawa
        stefana tadeusza wladyslawa wojciecha
      ].include?(token)
    end

    def normalized_street_number(value)
      normalized_text(value).delete(' ').upcase
    end

    def normalized_text(value)
      ActiveSupport::Inflector.transliterate(value.to_s)
        .downcase
        .gsub(/[[:punct:]]+/, ' ')
        .squeeze(' ')
        .strip
    end

    def precision(result)
      return unless result

      location_type = result.dig('geometry', 'location_type')
      types = Array(result['types']).sort.join('|')
      [location_type, types].compact.join('/')
    end

    def place_precision(place)
      return unless place

      types = Array(place['types']).sort.join('|')
      ['PLACES/text_search', types.presence].compact.join('/')
    end

    def place_confidence(place)
      return unless place

      types = Array(place['types'])
      return 0.95 if (types & %w[street_address premise subpremise]).any?
      return 0.9 if (types & %w[establishment point_of_interest store restaurant food]).any?

      0.7
    end

    def confidence(result)
      return unless result

      return 1.0 if result.dig('geometry', 'location_type') == 'ROOFTOP'
      return 0.8 if result.dig('geometry', 'location_type') == 'RANGE_INTERPOLATED'
      return 0.6 if result.dig('geometry', 'location_type') == 'GEOMETRIC_CENTER'

      0.4
    end

    def improves_location?(transformed_location, result)
      google_quality(result) > selected_quality(transformed_location)
    end

    def selected_quality(transformed_location)
      selected = transformed_location.geocoding_results.where(selected: true).order(id: :desc).first
      return 0 unless selected
      return 0 if selected.source == SOURCE && !stored_result_matches_location?(selected, transformed_location)
      return google_quality(selected) if selected.source == SOURCE
      return 110 if selected.source == 'uldk' && selected.precision.to_s.start_with?('parcel/')
      return nominatim_quality(selected) if selected.source == 'nominatim' && selected.strategy == 'address_point' && !imprecise_precision?(selected.precision)
      return 60 if selected.source == 'manual_geo_completion' && selected.precision.to_s.start_with?('derived/exact_parcel')
      return 55 if selected.precision.to_s.start_with?('derived/parcel/')
      return 45 if selected.precision.to_s.start_with?('derived/')
      return 40 if selected.strategy == 'street_fallback' || selected.strategy == 'teryt_named_object'
      return 35 if imprecise_precision?(selected.precision)

      75
    end

    def nominatim_quality(result)
      return 85 if nominatim_krakow_result?(result)

      30
    end

    def google_quality(result)
      precision = result.precision.to_s
      types = precision.delete_prefix('PLACES/text_search/').split('|') if precision.start_with?('PLACES/text_search/')
      types ||= precision.split('/', 2)[1].to_s.split('|')
      return 96 if precision.start_with?('PLACES/text_search/') && (types & %w[street_address premise subpremise]).any?
      return 92 if precision.start_with?('PLACES/text_search/') && (types & %w[establishment point_of_interest store restaurant food]).any?
      return 100 if precision.start_with?('ROOFTOP/') && (types & Geocoding::LocationUncertainty::PRECISE_GOOGLE_TYPES).any?
      return 72 if precision == 'RANGE_INTERPOLATED/street_address'
      return 74 if precision.start_with?('GEOMETRIC_CENTER/') && (types & %w[premise street_address establishment point_of_interest store]).any?
      return 20 if precision.start_with?('GEOMETRIC_CENTER/route')
      return 10 if precision.start_with?('APPROXIMATE/')

      0
    end

    def imprecise_precision?(precision)
      precision.to_s.match?(Geocoding::LocationUncertainty::IMPRECISE_PRECISION_PATTERN)
    end

    def nominatim_krakow_result?(result)
      response = JSON.parse(result.raw_response)
      Array(response['body']).any? do |item|
        address = item['address'] || {}
        address['city'] == 'Kraków' ||
          address['town'] == 'Kraków' ||
          address['county'] == 'Kraków' ||
          address['city_district'] == 'Kraków'
      end
    rescue JSON::ParserError, TypeError
      false
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
