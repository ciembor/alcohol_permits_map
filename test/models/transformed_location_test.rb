require 'test_helper'

class TransformedLocationTest < ActiveSupport::TestCase
  test 'stores coordinates in source-specific geocoder columns' do
    location = TransformedLocation.create!(
      address_1: 'Długa',
      building_number: '10',
      address_kind: 'street_address'
    )

    location.store_geocoder_coordinates!('krakow_msip', 50.1, 19.9)
    location.store_geocoder_coordinates!('google', 50.2, 19.8)

    location.reload
    assert_equal 50.1, location.krakow_msip_latitude
    assert_equal 19.9, location.krakow_msip_longitude
    assert_equal 50.2, location.google_latitude
    assert_equal 19.8, location.google_longitude
  end

  test 'building address is geocodable as address point' do
    location = TransformedLocation.new(
      address_1: 'Długa',
      building_number: '10',
      address_kind: 'street_address'
    )

    assert location.geocodable?
    assert_equal 'Długa 10 Kraków', location.geocoding_address
    assert_equal 'address_point', location.geocoding_strategy
    assert_equal [
      { strategy: 'address_point', query: 'Długa 10 Kraków', street: 'Długa', number: '10' },
      { strategy: 'street_fallback', query: 'Długa Kraków' }
    ], location.geocoding_queries
  end

  test 'building address prefers same_as current street for address point queries' do
    location = TransformedLocation.new(
      address_1: 'Jana Szwai',
      building_number: '12',
      address_kind: 'street_address',
      same_as: 'prof. Władysława Konopczyńskiego'
    )

    assert_equal [
      { strategy: 'address_point', query: 'prof. Władysława Konopczyńskiego 12 Kraków', street: 'prof. Władysława Konopczyńskiego', number: '12' },
      { strategy: 'historical_address_point', query: 'Jana Szwai 12 Kraków', street: 'Jana Szwai', number: '12' },
      { strategy: 'street_fallback', query: 'Jana Szwai Kraków' }
    ], location.geocoding_queries
    assert_equal ['prof. Władysława Konopczyńskiego'], location.geocoding_payload.fetch(:same_as)
  end

  test 'parcel address is geocodable as cadastral parcel' do
    location = TransformedLocation.new(
      address_1: 'Długa',
      parcel_number: '115/4',
      address_kind: 'parcel'
    )

    assert location.geocodable?
    assert_equal 'Długa dz. 115/4 Kraków', location.geocoding_address
    assert_equal 'cadastral_parcel', location.geocoding_strategy
    assert_equal [
      { strategy: 'cadastral_parcel', query: 'Długa dz. 115/4 Kraków' },
      { strategy: 'street_fallback', query: 'Długa Kraków' }
    ], location.geocoding_queries
  end

  test 'parcel address includes cadastral region and unit when present' do
    location = TransformedLocation.new(
      address_1: 'Litewska',
      parcel_number: '112',
      parcel_region: '46',
      parcel_cadastral_unit: 'krowodrza',
      address_kind: 'parcel'
    )

    assert_equal 'Litewska dz. 112 obr. 46 Krowodrza Kraków', location.geocoding_address
    assert_equal [
      { strategy: 'cadastral_parcel', query: 'Litewska dz. 112 obr. 46 Krowodrza Kraków' },
      { strategy: 'street_fallback', query: 'Litewska Kraków' }
    ], location.geocoding_queries
  end

  test 'parcel address expands multiple parcel numbers and regions into separate geocoding queries' do
    location = TransformedLocation.new(
      address_1: 'Henryka i Karola Czeczów',
      parcel_number: '471/8|471/9',
      parcel_region: '104|105',
      parcel_cadastral_unit: 'podgorze',
      address_kind: 'parcel'
    )

    assert_equal [
      { strategy: 'cadastral_parcel', query: 'Henryka i Karola Czeczów dz. 471/8 obr. 104 Podgórze Kraków' },
      { strategy: 'cadastral_parcel', query: 'Henryka i Karola Czeczów dz. 471/9 obr. 104 Podgórze Kraków' },
      { strategy: 'cadastral_parcel', query: 'Henryka i Karola Czeczów dz. 471/8 obr. 105 Podgórze Kraków' },
      { strategy: 'cadastral_parcel', query: 'Henryka i Karola Czeczów dz. 471/9 obr. 105 Podgórze Kraków' },
      { strategy: 'street_fallback', query: 'Henryka i Karola Czeczów Kraków' }
    ], location.geocoding_queries
  end

  test 'raw descriptive address is geocodable as described place' do
    location = TransformedLocation.new(
      address_1: 'Zakopiańska',
      raw_address_2: 'Borek Fałęcki pętla tramwajowa',
      address_kind: 'landmark'
    )

    assert location.geocodable?
    assert_equal 'Borek Fałęcki pętla tramwajowa Zakopiańska Kraków', location.geocoding_address
    assert_equal 'described_place', location.geocoding_strategy
    assert_equal [
      { strategy: 'described_place', query: 'Borek Fałęcki pętla tramwajowa Zakopiańska Kraków' },
      { strategy: 'street_fallback', query: 'Zakopiańska Kraków' }
    ], location.geocoding_queries
  end

  test 'street-only address is geocodable as fallback' do
    location = TransformedLocation.new(
      address_1: 'Krakowska',
      address_kind: 'landmark'
    )

    assert location.geocodable?
    assert_equal 'Krakowska Kraków', location.geocoding_address
    assert_equal 'street_fallback', location.geocoding_strategy
  end

  test 'TERYT named object is geocodable without building number' do
    Street.create!(trait: 'inne', name_1: 'Zamek Wawel')
    location = TransformedLocation.new(
      address_1: 'Zamek Wawel',
      address_kind: 'landmark'
    )

    assert location.geocodable?
    assert_equal 'Zamek Wawel Kraków', location.geocoding_address
    assert_equal 'teryt_named_object', location.geocoding_strategy
  end

  test 'pavilion without raw source text uses pavilion number as description' do
    location = TransformedLocation.new(
      address_1: 'Rynek Kleparski',
      unit_number: '17',
      address_kind: 'pavilion'
    )

    assert location.geocodable?
    assert_equal 'pawilon 17 Rynek Kleparski Kraków', location.geocoding_address
    assert_equal 'described_place', location.geocoding_strategy
  end
end
