require 'test_helper'

module TransformedLocations
  class SelectedGeocodingResultUpdaterTest < ActiveSupport::TestCase
    test 'marks the used geocoding result as selected and clears previous selections' do
      location = TransformedLocation.create!(
        address_1: 'Rynek Glowny',
        building_number: '1',
        address_kind: 'street_address'
      )
      previous = GeocodingResult.create!(
        transformed_location: location,
        source: 'krakow_msip',
        strategy: 'address_point',
        query: 'Rynek Glowny 1',
        latitude: 50.061,
        longitude: 19.937,
        selected: true
      )
      result = GeocodingResult.create!(
        transformed_location: location,
        source: 'google',
        strategy: 'address',
        query: 'Rynek Glowny 1, Krakow',
        latitude: 50.062,
        longitude: 19.938,
        selected: false
      )

      location.use_geocoding_result!(result)

      assert_not previous.reload.selected?
      assert result.reload.selected?
      assert_equal result.id, location.reload.selected_geocoding_result_id
      assert_equal 'google', location.selected_geocoding_source
      assert_equal 50.062, location.latitude
      assert_equal 19.938, location.longtitude
    end
  end
end
