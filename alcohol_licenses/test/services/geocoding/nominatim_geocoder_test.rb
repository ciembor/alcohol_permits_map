require 'test_helper'
require 'geocoding/nominatim_geocoder'

class Geocoding::NominatimGeocoderTest < ActiveSupport::TestCase
  FakeClient = Struct.new(:response, :calls) do
    def search(_query)
      self.calls += 1
      response
    end
  end

  test 'stores and selects successful address point result' do
    transformed_location = TransformedLocation.create!(
      address_1: 'Długa',
      building_number: '10',
      address_kind: 'street_address'
    )
    client = FakeClient.new({
      status: 200,
      body: [
        {
          'lat' => '50.0641',
          'lon' => '19.9391',
          'importance' => 0.8,
          'class' => 'place',
          'type' => 'house',
          'addresstype' => 'building',
          'address' => { 'city' => 'Kraków' }
        }
      ]
    }, 0)

    result = Geocoding::NominatimGeocoder.new(client: client, throttle_seconds: 0).geocode(transformed_location)

    assert result.selected?
    assert_equal 'nominatim', result.source
    assert_equal 'address_point', result.strategy
    assert_equal 50.0641, result.latitude
    assert_equal 19.9391, result.longitude
    transformed_location.reload
    assert_equal 50.0641, transformed_location.latitude
    assert_equal 50.0641, transformed_location.nominatim_latitude
    assert_equal 19.9391, transformed_location.nominatim_longitude
    assert_equal 1, client.calls
  end

  test 'does not call client when result already exists' do
    transformed_location = TransformedLocation.create!(
      address_1: 'Długa',
      building_number: '10',
      address_kind: 'street_address'
    )
    existing_result = GeocodingResult.create!(
      transformed_location: transformed_location,
      source: 'nominatim',
      strategy: 'address_point',
      query: 'Długa 10 Kraków'
    )
    client = FakeClient.new({ status: 200, body: [] }, 0)

    result = Geocoding::NominatimGeocoder.new(client: client, throttle_seconds: 0).geocode(transformed_location)

    assert_equal existing_result, result
    assert_equal 0, client.calls
  end

  test 'selects first result inside Krakow city' do
    transformed_location = TransformedLocation.create!(
      address_1: 'Dworcowa',
      building_number: '10',
      address_kind: 'street_address'
    )
    client = FakeClient.new({
      status: 200,
      body: [
        {
          'lat' => '49.966177',
          'lon' => '19.7729029',
          'importance' => 0.7,
          'class' => 'place',
          'type' => 'house',
          'addresstype' => 'place',
          'address' => { 'village' => 'Borek Szlachecki' }
        },
        {
          'lat' => '50.0337969',
          'lon' => '19.9726262',
          'importance' => 0.5,
          'class' => 'highway',
          'type' => 'residential',
          'addresstype' => 'road',
          'address' => { 'city' => 'Kraków' }
        }
      ]
    }, 0)

    result = Geocoding::NominatimGeocoder.new(client: client, throttle_seconds: 0).geocode(transformed_location)

    assert result.selected?
    assert_equal 50.0337969, result.latitude
    assert_equal 19.9726262, result.longitude
    assert_equal 50.0337969, transformed_location.reload.latitude
  end

  test 'geocodes configured cadastral parcel strategy' do
    transformed_location = TransformedLocation.create!(
      address_1: 'Długa',
      parcel_number: '115/4',
      address_kind: 'parcel'
    )
    client = FakeClient.new({
      status: 200,
      body: [
        {
          'lat' => '50.0642',
          'lon' => '19.9392',
          'importance' => 0.5,
          'class' => 'place',
          'type' => 'plot',
          'addresstype' => 'place',
          'address' => { 'city' => 'Kraków' }
        }
      ]
    }, 0)

    result = Geocoding::NominatimGeocoder.new(
      client: client,
      throttle_seconds: 0,
      strategy: 'cadastral_parcel'
    ).geocode(transformed_location)

    assert result.selected?
    assert_equal 'cadastral_parcel', result.strategy
    assert_equal 'Długa dz. 115/4 Kraków', result.query
    transformed_location.reload
    assert_equal 50.0642, transformed_location.latitude
    assert_equal 50.0642, transformed_location.nominatim_latitude
    assert_equal 19.9392, transformed_location.nominatim_longitude
    assert_equal 1, client.calls
  end
end
