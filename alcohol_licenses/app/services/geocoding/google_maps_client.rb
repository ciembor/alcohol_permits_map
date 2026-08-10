require 'json'
require 'net/http'
require 'uri'

module Geocoding
  class GoogleMapsClient
    ENDPOINT = 'https://maps.googleapis.com/maps/api/geocode/json'.freeze
    PLACES_TEXT_SEARCH_ENDPOINT = 'https://places.googleapis.com/v1/places:searchText'.freeze
    KRAKOW_BOUNDS = '49.95,19.75|50.16,20.25'.freeze
    KRAKOW_CENTER = { latitude: 50.06143, longitude: 19.93658 }.freeze

    def initialize(api_key: ENV['GOOGLE_MAPS_API_KEY'])
      @api_key = api_key
    end

    def search(query)
      raise ArgumentError, 'GOOGLE_MAPS_API_KEY is required' if api_key.to_s.strip.empty?

      uri = URI(ENDPOINT)
      uri.query = URI.encode_www_form(params(query))

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, open_timeout: 10, read_timeout: 30) do |http|
        http.request(Net::HTTP::Get.new(uri))
      end

      {
        status: response.code.to_i,
        body: parse_response(response.body)
      }
    end

    def text_search(query)
      raise ArgumentError, 'GOOGLE_MAPS_API_KEY is required' if api_key.to_s.strip.empty?

      uri = URI(PLACES_TEXT_SEARCH_ENDPOINT)
      request = Net::HTTP::Post.new(uri)
      request['Content-Type'] = 'application/json'
      request['X-Goog-Api-Key'] = api_key
      request['X-Goog-FieldMask'] = [
        'places.id',
        'places.displayName',
        'places.formattedAddress',
        'places.location',
        'places.addressComponents',
        'places.types',
        'places.primaryType'
      ].join(',')
      request.body = places_params(query).to_json

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, open_timeout: 10, read_timeout: 30) do |http|
        http.request(request)
      end

      {
        status: response.code.to_i,
        body: parse_response(response.body)
      }
    end

    private

    attr_reader :api_key

    def params(query)
      {
        address: query,
        key: api_key,
        language: 'pl',
        region: 'pl',
        components: 'country:PL',
        bounds: KRAKOW_BOUNDS
      }
    end

    def places_params(query)
      {
        textQuery: query,
        languageCode: 'pl',
        regionCode: 'PL',
        locationBias: {
          circle: {
            center: KRAKOW_CENTER,
            radius: 15_000.0
          }
        }
      }
    end

    def parse_response(body)
      JSON.parse(body)
    rescue JSON::ParserError
      body
    end
  end
end
