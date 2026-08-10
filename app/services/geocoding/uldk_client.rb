require 'net/http'
require 'uri'

module Geocoding
  class UldkClient
    ENDPOINT = 'https://uldk.gugik.gov.pl/'.freeze

    def search_parcel(parcel_id)
      uri = URI(ENDPOINT)
      uri.query = URI.encode_www_form(
        request: 'GetParcelById',
        id: parcel_id,
        result: 'id,voivodeship,county,commune,region,parcel,geom_wkt,datasource',
        srid: '4326'
      )

      response = Net::HTTP.get_response(uri)

      {
        status: response.code.to_i,
        url: uri.to_s,
        body: response.body
      }
    end
  end
end
