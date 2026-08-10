require 'json'
require 'net/http'
require 'uri'

module Geocoding
  class NominatimClient
    ENDPOINT = 'https://nominatim.openstreetmap.org/search'.freeze
    KRAKOW_VIEWBOX = '19.75,50.16,20.25,49.95'.freeze

    def initialize(user_agent: default_user_agent, email: ENV['NOMINATIM_EMAIL'])
      @user_agent = user_agent
      @email = email
    end

    def search(query, limit: 5)
      uri = URI(ENDPOINT)
      uri.query = URI.encode_www_form(params(query, limit: limit))

      request = Net::HTTP::Get.new(uri)
      request['User-Agent'] = user_agent

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, open_timeout: 10, read_timeout: 30) do |http|
        http.request(request)
      end

      {
        status: response.code.to_i,
        body: parse_response(response.body)
      }
    end

    private

    attr_reader :user_agent, :email

    def params(query, limit:)
      {
        q: query,
        format: 'jsonv2',
        addressdetails: 1,
        limit: limit,
        countrycodes: 'pl',
        viewbox: KRAKOW_VIEWBOX,
        bounded: 1,
        email: email
      }.compact
    end

    def parse_response(body)
      JSON.parse(body)
    rescue JSON::ParserError
      body
    end

    def default_user_agent
      'krakow-alcohol-licenses-geocoder/1.0'
    end
  end
end
