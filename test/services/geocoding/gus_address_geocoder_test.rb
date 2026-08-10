require 'test_helper'
require 'geocoding/gus_address_geocoder'

class Geocoding::GusAddressGeocoderTest < ActiveSupport::TestCase
  class FakeClient
    attr_reader :queries

    def initialize(response)
      @response = response
      @queries = []
    end

    def search(query, street:, number:, postal_code: nil)
      queries << { query: query, street: street, number: number, postal_code: postal_code }
      @response
    end
  end

  test 'stores source-specific coordinates for successful GUS address point' do
    transformed_location = TransformedLocation.create!(
      address_1: 'Długa',
      building_number: '10',
      address_kind: 'street_address'
    )
    client = FakeClient.new({
      status: 200,
      body: [
        {
          'relevance' => 1.0,
          'single' => {
            'id' => 'gus-1',
            'ul_pelna' => 'Długa',
            'pkt_numer' => '10',
            'pkt_kodPocztowy' => '31-147',
            'teryt' => '126101',
            'geometry' => {
              'coordinates' => [19.9391, 50.0641]
            },
            'record' => {
              'properties' => {
                'pow_idteryt' => '1261'
              }
            }
          }
        }
      ]
    })

    result = Geocoding::GusAddressGeocoder.new(client: client).geocode(transformed_location)

    assert result.selected?
    transformed_location.reload
    assert_equal 50.0641, transformed_location.gus_latitude
    assert_equal 19.9391, transformed_location.gus_longitude
    assert_equal 50.0641, transformed_location.latitude
    assert_equal 19.9391, transformed_location.longtitude
  end

  test 'does not store coordinates when GUS returns a Krakow point for a different street' do
    transformed_location = TransformedLocation.create!(
      address_1: 'Balicka',
      building_number: '14A',
      address_kind: 'street_address'
    )
    client = FakeClient.new({
      status: 200,
      body: [
        {
          'relevance' => 1.0,
          'single' => {
            'id' => 'gus-2',
            'ul_pelna' => 'Halicka',
            'pkt_numer' => '14A',
            'teryt' => '126101',
            'geometry' => {
              'coordinates' => [19.952343347, 50.051324989]
            },
            'record' => {
              'properties' => {
                'pow_idteryt' => '1261'
              }
            }
          }
        }
      ]
    })

    result = Geocoding::GusAddressGeocoder.new(client: client).geocode(transformed_location)

    assert_not result.selected?
    assert_nil result.latitude
    assert_nil result.longitude
    transformed_location.reload
    assert_nil transformed_location.gus_latitude
    assert_nil transformed_location.gus_longitude
  end

  test 'does not match streets that only become equal after removing diacritics' do
    transformed_location = TransformedLocation.create!(
      address_1: 'Sadowa',
      building_number: '9',
      address_kind: 'street_address'
    )
    client = FakeClient.new({
      status: 200,
      body: [
        {
          'relevance' => 0.975,
          'single' => {
            'id' => 'gus-3',
            'ul_pelna' => 'ul. Sądowa',
            'pkt_numer' => '9',
            'teryt' => '1261011',
            'geometry' => {
              'coordinates' => [19.962553662, 50.062274543]
            },
            'record' => {
              'properties' => {
                'pow_idteryt' => '1261'
              }
            }
          }
        }
      ]
    })

    result = Geocoding::GusAddressGeocoder.new(client: client).geocode(transformed_location)

    assert_not result.selected?
    assert_nil result.latitude
    assert_nil result.longitude
    transformed_location.reload
    assert_nil transformed_location.gus_latitude
    assert_nil transformed_location.gus_longitude
  end

  test 'uses same_as current street as the GUS address point query' do
    transformed_location = TransformedLocation.create!(
      address_1: 'Jana Szwai',
      building_number: '16',
      address_kind: 'street_address',
      same_as: 'prof. Władysława Konopczyńskiego'
    )
    client = FakeClient.new({
      status: 200,
      body: [
        {
          'relevance' => 1.0,
          'single' => {
            'id' => 'gus-4',
            'ul_pelna' => 'prof. Władysława Konopczyńskiego',
            'pkt_numer' => '16',
            'teryt' => '126101',
            'geometry' => {
              'coordinates' => [19.896267838, 50.018315546]
            },
            'record' => {
              'properties' => {
                'pow_idteryt' => '1261'
              }
            }
          }
        }
      ]
    })

    result = Geocoding::GusAddressGeocoder.new(client: client).geocode(transformed_location)

    assert result.selected?
    assert_equal [
      {
        query: 'prof. Władysława Konopczyńskiego 16 Kraków',
        street: 'prof. Władysława Konopczyńskiego',
        number: '16',
        postal_code: nil
      }
    ], client.queries
    transformed_location.reload
    assert_equal 50.018315546, transformed_location.gus_latitude
    assert_equal 19.896267838, transformed_location.gus_longitude
  end
end
