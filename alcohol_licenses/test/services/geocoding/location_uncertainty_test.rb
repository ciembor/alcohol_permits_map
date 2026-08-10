require 'test_helper'
require 'geocoding/location_uncertainty'

module Geocoding
  class LocationUncertaintyTest < ActiveSupport::TestCase
    test 'marks fallback road results as uncertain' do
      reasons = LocationUncertainty.reasons(
        geocoding_source: 'nominatim',
        geocoding_strategy: 'street_fallback',
        geocoding_precision: 'residential/road',
        address_kind: 'street_address'
      )

      assert_includes reasons, 'wynik z przybliżonej strategii: street_fallback'
      assert_includes reasons, 'mało precyzyjny wynik geokodowania: residential/road'
    end

    test 'marks unconfirmed parcel results as uncertain' do
      reasons = LocationUncertainty.reasons(
        geocoding_source: 'uldk',
        geocoding_strategy: 'cadastral_parcel',
        geocoding_precision: 'derived/parcel/S-3',
        address_kind: 'parcel'
      )

      assert_includes reasons, 'działka bez jednoznacznego dopasowania w ewidencji'
      assert_includes reasons, 'mało precyzyjny wynik geokodowania: derived/parcel/S-3'
    end

    test 'accepts precise google rooftop results' do
      assert_empty LocationUncertainty.reasons(
        geocoding_source: 'google',
        geocoding_strategy: 'street_fallback',
        geocoding_precision: 'ROOFTOP/establishment|point_of_interest',
        address_kind: 'parcel'
      )
    end

    test 'keeps approximate google results uncertain' do
      reasons = LocationUncertainty.reasons(
        geocoding_source: 'google',
        geocoding_strategy: 'street_fallback',
        geocoding_precision: 'APPROXIMATE/route',
        address_kind: 'street_address'
      )

      assert_includes reasons, 'wynik z przybliżonej strategii: street_fallback'
    end
  end
end
