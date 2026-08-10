require 'test_helper'
require 'geocoding/google_maps_geocoder'

module Geocoding
  class GoogleMapsGeocoderTest < ActiveSupport::TestCase
    test 'does not confuse Plac Nowy Kleparz kiosk with Plac Nowy' do
      geocoder = GoogleMapsGeocoder.new
      location = TransformedLocation.new(
        address_1: 'Plac Nowy Kleparz',
        address_kind: 'pavilion',
        unit_number: '13',
        raw_address_2: 'KIOSK NR 13'
      )

      assert_equal 'Plac Nowy Kleparz Kraków', geocoder.send(:query_for, location)
    end

    test 'accepts google locality variants prefixed with Kraków' do
      geocoder = GoogleMapsGeocoder.new
      response = {
        body: {
          'results' => [
            {
              'address_components' => [
                { 'long_name' => 'Kraków-Śródmieście', 'short_name' => 'Kraków-Śródmieście' }
              ],
              'geometry' => { 'location_type' => 'ROOFTOP' },
              'types' => %w[premise street_address]
            }
          ]
        }
      }

      assert geocoder.send(:best_result, response)
    end

    test 'accepts city county but not surrounding Kraków county' do
      geocoder = GoogleMapsGeocoder.new
      city_response = google_response_with_component('Powiat Kraków')
      suburban_response = google_response_with_component('Powiat krakowski')

      assert geocoder.send(:best_result, city_response)
      assert_nil geocoder.send(:best_result, suburban_response)
    end

    test 'rejects google result with Kraków component but coordinates outside SIM areas' do
      geocoder = GoogleMapsGeocoder.new
      location = TransformedLocation.new(
        address_1: 'Komandosów',
        building_number: '1',
        address_kind: 'street_address'
      )
      response = {
        body: {
          'results' => [
            google_result('Komandosów', '1', latitude: 50.1177836, longitude: 19.8374044),
            google_result('Komandosów', '1', latitude: 50.0456259, longitude: 19.9306909)
          ]
        }
      }

      result = geocoder.send(:best_result, response, location)

      assert_equal 50.0456259, result.dig('geometry', 'location', 'lat')
      assert_equal 19.9306909, result.dig('geometry', 'location', 'lng')
    end

    test 'adds street-prefixed fallback for street addresses' do
      geocoder = GoogleMapsGeocoder.new
      location = TransformedLocation.new(
        address_1: 'Kamienna',
        building_number: '5',
        address_kind: 'street_address'
      )

      assert_equal ['Kamienna 5 Kraków', 'ulica Kamienna 5 Kraków'], geocoder.send(:queries_for, location)
    end

    test 'uses google places when geocoding drops building suffix' do
      location = TransformedLocation.create!(
        address_1: 'Mogilska',
        building_number: '21L',
        address_kind: 'street_address'
      )
      geocoder = GoogleMapsGeocoder.new(
        client: FakeGoogleClient.new(
          geocoding_response: google_geocoding_response('Mogilska', '21'),
          places_response: google_places_response('Mogilska 21L, Kraków, Polska', 50.066, 19.961)
        ),
        throttle_seconds: 0
      )

      result = geocoder.geocode(location)

      assert_equal 'places:text: Mogilska 21L Kraków', result.query
      assert result.selected?
      location.reload
      assert_equal 50.066, location.latitude
      assert_equal 19.961, location.longtitude
      assert_equal 50.066, location.google_latitude
      assert_equal 19.961, location.google_longitude
    end

    test 'does not use places text search for parcels' do
      geocoder = GoogleMapsGeocoder.new
      location = TransformedLocation.new(
        address_1: 'Bulwar Kurlandzki',
        parcel_number: '137/7',
        address_kind: 'parcel'
      )

      assert_empty geocoder.send(:places_queries_for, location)
    end

    test 'downgrades nominatim address point outside Kraków' do
      geocoder = GoogleMapsGeocoder.new
      result = GeocodingResult.new(
        source: 'nominatim',
        strategy: 'address_point',
        precision: 'yes/building',
        raw_response: {
          status: 200,
          body: [
            { address: { village: 'Rząska', county: 'powiat krakowski' } }
          ]
        }.to_json
      )

      assert_equal 30, geocoder.send(:nominatim_quality, result)
    end

    test 'rejects google result with different street number suffix' do
      geocoder = GoogleMapsGeocoder.new
      location = TransformedLocation.new(
        address_1: 'Mogilska',
        building_number: '21L',
        address_kind: 'street_address'
      )
      result = google_result('Mogilska', '21')

      assert_not geocoder.send(:result_matches_location?, result, location)
    end

    test 'accepts normalized base building number' do
      geocoder = GoogleMapsGeocoder.new
      location = TransformedLocation.new(
        address_1: 'Pawia',
        building_number: '5',
        address_kind: 'street_address'
      )
      result = google_result('Pawia', '5')

      assert geocoder.send(:result_matches_location?, result, location)
    end

    test 'keeps normalized building letter strict' do
      geocoder = GoogleMapsGeocoder.new
      location = TransformedLocation.new(
        address_1: 'Igołomska',
        building_number: '30L',
        address_kind: 'street_address'
      )
      result = google_result('Igołomska', '30')

      assert_not geocoder.send(:result_matches_location?, result, location)
    end

    test 'rejects google result with different route' do
      geocoder = GoogleMapsGeocoder.new
      location = TransformedLocation.new(
        address_1: 'Stróża Rybna',
        building_number: '16D',
        address_kind: 'street_address'
      )
      result = google_result('Rybna', '16d')

      assert_not geocoder.send(:result_matches_location?, result, location)
    end

    test 'accepts common route and number formatting variants' do
      geocoder = GoogleMapsGeocoder.new

      aleja = TransformedLocation.new(address_1: 'Aleja 3 Maja', building_number: '9', address_kind: 'street_address')
      jagielly = TransformedLocation.new(address_1: 'Władysława Jagiełły', building_number: '31A', address_kind: 'street_address')
      osiedle = TransformedLocation.new(address_1: 'Osiedle Kolorowe', building_number: '16A', address_kind: 'street_address')

      assert geocoder.send(:result_matches_location?, google_result('al. 3 Maja', '9'), aleja)
      assert geocoder.send(:result_matches_location?, google_result('Władysława Jagiełły', '31 A'), jagielly)
      assert geocoder.send(:result_matches_location?, google_result('Os. Kolorowe', '16A'), osiedle)
    end

    private

    def google_result(route, street_number, latitude: nil, longitude: nil)
      {
        'address_components' => [
          { 'long_name' => street_number, 'short_name' => street_number, 'types' => ['street_number'] },
          { 'long_name' => route, 'short_name' => route, 'types' => ['route'] },
          { 'long_name' => 'Kraków', 'short_name' => 'Kraków', 'types' => %w[locality political] }
        ],
        'geometry' => {
          'location_type' => 'ROOFTOP',
          'location' => latitude && longitude ? { 'lat' => latitude, 'lng' => longitude } : nil
        },
        'types' => %w[premise street_address]
      }
    end

    def google_geocoding_response(route, street_number)
      {
        status: 200,
        body: {
          'status' => 'OK',
          'results' => [google_result(route, street_number)]
        }
      }
    end

    def google_places_response(formatted_address, latitude, longitude)
      {
        status: 200,
        body: {
          'places' => [
            {
              'formattedAddress' => formatted_address,
              'location' => { 'latitude' => latitude, 'longitude' => longitude },
              'types' => %w[street_address],
              'addressComponents' => [
                { 'longText' => 'Mogilska', 'shortText' => 'Mogilska', 'types' => ['route'] },
                { 'longText' => '21L', 'shortText' => '21L', 'types' => ['street_number'] },
                { 'longText' => 'Kraków', 'shortText' => 'Kraków', 'types' => %w[locality political] }
              ]
            }
          ]
        }
      }
    end

    def google_response_with_component(component)
      {
        body: {
          'results' => [
            {
              'address_components' => [
                { 'long_name' => component, 'short_name' => component }
              ],
              'geometry' => { 'location_type' => 'ROOFTOP' },
              'types' => %w[premise street_address]
            }
          ]
        }
      }
    end

    class FakeGoogleClient
      def initialize(geocoding_response:, places_response:)
        @geocoding_response = geocoding_response
        @places_response = places_response
      end

      def search(_query)
        @geocoding_response
      end

      def text_search(_query)
        @places_response
      end
    end
  end
end
