require 'test_helper'
require 'geocoding/krakow_msip_address_geocoder'

class Geocoding::KrakowMsipAddressGeocoderTest < ActiveSupport::TestCase
  FakeClient = Struct.new(:responses, :queries) do
    def search(street:, number:)
      queries << [street, number]
      responses.fetch([street, number]) { feature_collection([]) }
    end

    def feature_collection(features)
      {
        status: 200,
        url: 'https://example.test/query',
        body: {
          'type' => 'FeatureCollection',
          'features' => features
        }
      }
    end
  end

  test 'selects exact Kraków MSIP address point' do
    transformed_location = TransformedLocation.create!(
      address_1: 'Floriańska',
      building_number: '1',
      address_kind: 'street_address'
    )
    client = FakeClient.new({
      ['Floriańska', '1'] => feature_collection([feature('Floriańska', '1')])
    }, [])

    result = Geocoding::KrakowMsipAddressGeocoder.new(client: client).geocode(transformed_location)

    assert result.selected?
    assert_equal 'krakow_msip', result.source
    assert_equal 'address_point', result.strategy
    assert_equal 'Floriańska 1 Kraków', result.query
    assert_equal 'address_point/msip_emuia', result.precision
    assert_in_delta 50.062126557206966, result.latitude
    assert_in_delta 19.939376562349867, result.longitude
    transformed_location.reload
    assert_in_delta 50.062126557206966, transformed_location.latitude
    assert_in_delta 50.062126557206966, transformed_location.krakow_msip_latitude
    assert_in_delta 19.939376562349867, transformed_location.krakow_msip_longitude
    assert_equal [['Floriańska', '1']], client.queries
  end

  test 'does not select point with different address number' do
    transformed_location = TransformedLocation.create!(
      address_1: 'Floriańska',
      building_number: '1',
      address_kind: 'street_address'
    )
    client = FakeClient.new({
      ['Floriańska', '1'] => feature_collection([feature('Floriańska', '2')])
    }, [])

    result = Geocoding::KrakowMsipAddressGeocoder.new(client: client).geocode(transformed_location)

    assert_not result.selected?
    assert_nil result.latitude
    assert_nil result.longitude
  end

  test 'tries same_as current street before historical street' do
    transformed_location = TransformedLocation.create!(
      address_1: 'Jana Szwai',
      building_number: '12',
      address_kind: 'street_address',
      same_as: 'prof. Władysława Konopczyńskiego'
    )
    client = FakeClient.new({
      ['prof. Władysława Konopczyńskiego', '12'] => feature_collection([feature('prof. Władysława Konopczyńskiego', '12')])
    }, [])

    result = Geocoding::KrakowMsipAddressGeocoder.new(client: client).geocode(transformed_location)

    assert result.selected?
    assert_equal 'address_point', result.strategy
    assert_equal 'prof. Władysława Konopczyńskiego 12 Kraków', result.query
    assert_equal [
      ['prof. Władysława Konopczyńskiego', '12']
    ], client.queries
  end

  test 'returns existing MSIP result without duplicate request' do
    transformed_location = TransformedLocation.create!(
      address_1: 'Floriańska',
      building_number: '1',
      address_kind: 'street_address'
    )
    existing = GeocodingResult.create!(
      transformed_location: transformed_location,
      source: 'krakow_msip',
      strategy: 'address_point',
      query: 'Floriańska 1 Kraków',
      latitude: 50.0,
      longitude: 19.0
    )
    client = FakeClient.new({}, [])

    result = Geocoding::KrakowMsipAddressGeocoder.new(client: client).geocode(transformed_location)

    assert_equal existing, result
    assert_empty client.queries
  end

  test 'returns existing failed MSIP result when every candidate was already attempted' do
    transformed_location = TransformedLocation.create!(
      address_1: 'Floriańska',
      building_number: '1',
      address_kind: 'street_address'
    )
    existing = GeocodingResult.create!(
      transformed_location: transformed_location,
      source: 'krakow_msip',
      strategy: 'address_point',
      query: 'Floriańska 1 Kraków'
    )
    client = FakeClient.new({}, [])

    result = Geocoding::KrakowMsipAddressGeocoder.new(client: client).geocode(transformed_location)

    assert_equal existing, result
    assert_empty client.queries
  end

  private

  def feature_collection(features)
    {
      status: 200,
      url: 'https://example.test/query',
      body: {
        'type' => 'FeatureCollection',
        'features' => features
      }
    }
  end

  def feature(street, number)
    {
      'type' => 'Feature',
      'id' => 27508,
      'geometry' => {
        'type' => 'Point',
        'coordinates' => [19.939376562349867, 50.062126557206966]
      },
      'properties' => {
        'id' => 27508,
        'nazwa_ulicy' => street,
        'numer_adresowy' => number,
        'kod_pocztowy' => '31-042',
        'miejscowosc' => 'Kraków',
        'numer_dzielnicy' => '1',
        'nazwa_dzielnicy' => 'Dzielnica I Stare Miasto',
        'kod_teryt' => '05085'
      }
    }
  end
end
