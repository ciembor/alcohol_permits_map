require 'json'
require 'net/http'
require 'uri'

module Geocoding
  class KrakowMsipAddressClient
    ENDPOINT = 'https://msip3.um.krakow.pl/server/rest/services/Pobieranie/Adresy/MapServer/0/query'.freeze

    def initialize(endpoint: ENDPOINT)
      @endpoint = endpoint
    end

    def search(street:, number:)
      uri = URI(endpoint)
      uri.query = URI.encode_www_form(
        f: 'geojson',
        where: where_clause(street, number),
        outFields: '*',
        outSR: '4326',
        returnGeometry: 'true'
      )

      response = Net::HTTP.get_response(uri)

      {
        status: response.code.to_i,
        url: uri.to_s,
        body: parse_body(response.body)
      }
    end

    private

    attr_reader :endpoint

    def where_clause(street, number)
      [
        "miejscowosc = 'Kraków'",
        "nazwa_ulicy = '#{sql_literal(street)}'",
        "numer_adresowy = '#{sql_literal(number)}'"
      ].join(' AND ')
    end

    def sql_literal(value)
      value
        .to_s
        .dup
        .force_encoding('UTF-8')
        .encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
        .gsub("'", "''")
    end

    def parse_body(body)
      JSON.parse(body)
    rescue JSON::ParserError
      body
    end
  end
end
