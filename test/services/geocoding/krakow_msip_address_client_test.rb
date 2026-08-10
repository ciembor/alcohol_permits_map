require 'test_helper'
require 'geocoding/krakow_msip_address_client'

class Geocoding::KrakowMsipAddressClientTest < ActiveSupport::TestCase
  test 'builds ArcGIS REST where clause for Kraków address point' do
    client = Geocoding::KrakowMsipAddressClient.new(endpoint: 'https://example.test/query')

    where = client.send(:where_clause, "Świętego Jana", "1A")

    assert_includes where, "miejscowosc = 'Kraków'"
    assert_includes where, "nazwa_ulicy = 'Świętego Jana'"
    assert_includes where, "numer_adresowy = '1A'"
  end
end
