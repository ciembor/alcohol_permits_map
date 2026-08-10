require 'test_helper'
require 'geocoding/uldk_parcel_geocoder'

class Geocoding::UldkParcelGeocoderTest < ActiveSupport::TestCase
  FakeClient = Struct.new(:response, :queries) do
    def search_parcel(parcel_id)
      queries << parcel_id
      response
    end
  end

  LookupClient = Struct.new(:responses, :queries) do
    def search_parcel(parcel_id)
      queries << parcel_id
      responses.fetch(parcel_id, { status: 200, body: '' })
    end
  end

  test 'geocodes parcel with cadastral unit and region from raw address' do
    transformed_location = TransformedLocation.create!(
      address_1: 'Bulwar Czerwieński',
      parcel_number: '81/5',
      address_kind: 'parcel',
      raw_address_2: 'dz.nr 81/5 obr.146 śródmieście'
    )
    client = FakeClient.new({
      status: 200,
      body: [
        '0',
        '126105_9.0146.81/5|małopolskie|powiat Kraków|Kraków (miasto)|S-146|81/5|SRID=4326;POLYGON((19.0 50.0,20.0 50.0,20.0 51.0,19.0 50.0))|source'
      ].join("\n")
    }, [])

    result = Geocoding::UldkParcelGeocoder.new(client: client, throttle_seconds: 0).geocode(transformed_location)

    assert result.selected?
    assert_equal 'uldk', result.source
    assert_equal 'cadastral_parcel', result.strategy
    assert_equal '126105_9.0146.81/5', result.query
    assert_equal 'parcel/S-146', result.precision
    assert_equal ['126105_9.0146.81/5'], client.queries
    transformed_location.reload
    assert_in_delta 50.25, transformed_location.latitude
    assert_in_delta 19.5, transformed_location.longtitude
    assert_in_delta 50.25, transformed_location.uldk_latitude
    assert_in_delta 19.5, transformed_location.uldk_longitude
  end

  test 'stores empty result when parcel id cannot be built' do
    transformed_location = TransformedLocation.create!(
      address_1: 'Nieznana',
      parcel_number: '115/4',
      address_kind: 'parcel',
      raw_address_2: 'dz. 115/4'
    )
    client = FakeClient.new({ status: 200, body: '' }, [])

    result = Geocoding::UldkParcelGeocoder.new(client: client, throttle_seconds: 0).geocode(transformed_location)

    assert_nil result.latitude
    assert_equal 'Nieznana dz. 115/4 Kraków', result.query
    assert_empty client.queries
  end

  test 'builds parcel id candidates for multiple parcel numbers and regions' do
    transformed_location = TransformedLocation.create!(
      address_1: 'Henryka i Karola Czeczów',
      parcel_number: '471/8|471/9',
      parcel_region: '104|105',
      parcel_cadastral_unit: 'podgorze',
      address_kind: 'parcel',
      raw_address_2: 'działka 471/8 i 471/9 obr. 104,105'
    )
    client = FakeClient.new({ status: 200, body: '' }, [])

    Geocoding::UldkParcelGeocoder.new(client: client, throttle_seconds: 0).geocode(transformed_location)

    assert_equal [
      '126104_9.0104.471/8',
      '126104_9.0104.471/9',
      '126104_9.0105.471/8',
      '126104_9.0105.471/9'
    ], client.queries
  end

  test 'infers missing parcel region from street cadastral unit when exactly one parcel matches' do
    transformed_location = TransformedLocation.create!(
      address_1: 'Długa',
      parcel_number: '115/4',
      address_kind: 'parcel',
      raw_address_2: 'dz. 115/4'
    )
    parcel_id = '126105_9.0116.115/4'
    client = LookupClient.new({
      parcel_id => {
        status: 200,
        body: [
          '0',
          "#{parcel_id}|małopolskie|powiat Kraków|Kraków (miasto)|S-116|115/4|SRID=4326;POLYGON((19.0 50.0,20.0 50.0,20.0 51.0,19.0 50.0))|source"
        ].join("\n")
      }
    }, [])

    result = Geocoding::UldkParcelGeocoder.new(client: client, throttle_seconds: 0).geocode(transformed_location)

    assert result.selected?
    assert_equal parcel_id, result.query
    assert_equal 'parcel/S-116', result.precision
    assert_includes client.queries, parcel_id
    transformed_location.reload
    assert_equal 'uldk', transformed_location.selected_geocoding_source
    assert_in_delta 50.25, transformed_location.latitude
    assert_in_delta 19.5, transformed_location.longtitude
  end

  test 'does not select inferred parcel region when more than one region matches' do
    transformed_location = TransformedLocation.create!(
      address_1: 'Długa',
      parcel_number: '115/2',
      address_kind: 'parcel',
      raw_address_2: 'dz. 115/2'
    )
    first_id = '126105_9.0008.115/2'
    second_id = '126105_9.0059.115/2'
    client = LookupClient.new({
      first_id => {
        status: 200,
        body: [
          '0',
          "#{first_id}|małopolskie|powiat Kraków|Kraków (miasto)|S-8|115/2|SRID=4326;POLYGON((19.0 50.0,20.0 50.0,20.0 51.0,19.0 50.0))|source"
        ].join("\n")
      },
      second_id => {
        status: 200,
        body: [
          '0',
          "#{second_id}|małopolskie|powiat Kraków|Kraków (miasto)|S-59|115/2|SRID=4326;POLYGON((21.0 52.0,22.0 52.0,22.0 53.0,21.0 52.0))|source"
        ].join("\n")
      }
    }, [])

    result = Geocoding::UldkParcelGeocoder.new(client: client, throttle_seconds: 0).geocode(transformed_location)

    assert_not result.selected?
    assert_nil result.latitude
    assert_equal 'ambiguous: Długa dz. 115/2 Kraków', result.query
    assert_equal 'parcel/ambiguous', result.precision
    assert_includes client.queries, first_id
    assert_includes client.queries, second_id
    transformed_location.reload
    assert_nil transformed_location.selected_geocoding_source
  end

  test 'does not select inferred parcel result for multiple source parcel numbers unless unambiguous as a whole' do
    transformed_location = TransformedLocation.create!(
      address_1: 'Długa',
      parcel_number: '115/4|115/40',
      address_kind: 'parcel',
      raw_address_2: 'dz. 115/4 i 115/40'
    )
    parcel_id = '126105_9.0116.115/4'
    client = LookupClient.new({
      parcel_id => {
        status: 200,
        body: [
          '0',
          "#{parcel_id}|małopolskie|powiat Kraków|Kraków (miasto)|S-116|115/4|SRID=4326;POLYGON((19.0 50.0,20.0 50.0,20.0 51.0,19.0 50.0))|source"
        ].join("\n")
      }
    }, [])

    result = Geocoding::UldkParcelGeocoder.new(client: client, throttle_seconds: 0).geocode(transformed_location)

    assert_not result.selected?
    assert_nil result.latitude
    assert_equal 'ambiguous: Długa dz. 115/4 Kraków', result.query
    assert_equal 'parcel/ambiguous', result.precision
    transformed_location.reload
    assert_nil transformed_location.selected_geocoding_source
  end
end
