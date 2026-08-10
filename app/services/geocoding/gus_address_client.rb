require 'json'
require 'net/http'
require 'uri'

module Geocoding
  class GusAddressClient
    ENDPOINT = 'https://geo.stat.gov.pl/api/fts/gc/pkt'.freeze
    KRAKOW_COUNTY_TERYT = '1261'.freeze

    def search(query, street: nil, number: nil, postal_code: nil)
      uri = URI(ENDPOINT)

      request = Net::HTTP::Post.new(uri)
      request['Accept'] = 'application/json'
      request['Content-Type'] = 'application/json'
      request.body = request_body(
        query,
        street: street,
        number: number,
        postal_code: postal_code
      ).to_json

      response = Net::HTTP.start(
        uri.hostname,
        uri.port,
        use_ssl: true,
        open_timeout: 10,
        read_timeout: 30
      ) do |http|
        http.request(request)
      end

      {
        status: response.code.to_i,
        url: uri.to_s,
        body: parse_response(response.body)
      }
    end

    private

    def request_body(query, street:, number:, postal_code:)
      address = {
        pow_nazwa: 'Kraków',
        woj_nazwa: 'MAŁOPOLSKIE'
      }

      if street.to_s.strip != '' && number.to_s.strip != ''
        address[:ul_pelna] = street
        address[:pkt_numer] = number
        address[:pkt_kodPocztowy] = postal_code if postal_code.to_s.strip != ''
      else
        address[:q] = query
      end

      {
        epsg: 4326,
        reqs: [address],
        useExtServiceIfNotFound: false
      }
    end

    def parse_response(body)
      JSON.parse(body)
    rescue JSON::ParserError
      body
    end
  end
end
