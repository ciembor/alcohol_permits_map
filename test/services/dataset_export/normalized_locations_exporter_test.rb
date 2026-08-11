require 'test_helper'
require 'csv'
require 'json'
require 'tmpdir'

class DatasetExport::NormalizedLocationsExporterTest < ActiveSupport::TestCase
  setup do
    clear_dataset_records
    seed_normalized_location_records
  end

  teardown do
    clear_dataset_records
  end

  test 'writes normalized location rows with geocoding metadata and counts' do
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'locations_normalized.csv')
      count = DatasetExport::Exporters::NormalizedLocationsExporter.new(path: path).write

      assert_equal 2, count

      csv = CSV.read(path, headers: true, encoding: 'UTF-8')
      assert_equal DatasetExport::NormalizedLocationRows::COLUMNS, csv.headers
      assert_empty csv.headers.grep(/google/i)
      assert_empty csv.headers.grep(/\Ainternal_/)
      refute_includes csv.headers, 'raw_address_2'
      refute_includes csv.headers, 'selected_geocoding_query'

      rynek = csv.find { |row| row.fetch('address_1') == 'Rynek' }
      assert rynek.fetch('normalized_location_id').start_with?('normalized-location-')
      assert_equal 'EPSG:4326', rynek.fetch('crs')
      assert_equal 'krakow_msip', rynek.fetch('selected_geocoding_source')
      assert rynek.fetch('selected_geocoding_result_id').start_with?('geocoding-result-')
      assert_equal '2', rynek.fetch('raw_location_count')
      assert_equal '2', rynek.fetch('license_count')
      assert_equal '2026-01-01T00:00:00Z', rynek.fetch('first_reported_at')
      assert_equal '2026-02-01T00:00:00Z', rynek.fetch('last_reported_at')
      assert_equal [], JSON.parse(rynek.fetch('location_uncertainty_reasons'))

      parcel = csv.find { |row| row.fetch('address_1') == 'Działka' }
      assert_equal 'parcel', parcel.fetch('address_kind')
      assert_equal 'true', parcel.fetch('location_uncertain')
      assert JSON.parse(parcel.fetch('location_uncertainty_reasons')).any?
    end
  end

  test 'latest only limits rows and counts to newest report' do
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'locations_normalized.csv')
      count = DatasetExport::Exporters::NormalizedLocationsExporter.new(path: path, latest_only: true).write

      assert_equal 1, count
      csv = CSV.read(path, headers: true, encoding: 'UTF-8')
      assert_equal ['Rynek'], csv.map { |row| row.fetch('address_1') }
      assert_equal '1', csv.first.fetch('raw_location_count')
      assert_equal '1', csv.first.fetch('license_count')
    end
  end

  private

  def seed_normalized_location_records
    detail = BusinessCategory.create!(name: 'detal')
    category_a = LicenseCategory.create!(name: 'A', description: 'A')
    business = Business.create!(name: 'TEST BUSINESS')
    rynek = TransformedLocation.create!(
      address_1: 'Rynek',
      building_number: '1',
      address_kind: 'street_address',
      latitude: 50.061,
      longtitude: 19.936,
      selected_geocoding_source: 'krakow_msip',
      selected_geocoding_strategy: 'address_point',
      selected_geocoding_precision: 'address_point/building',
      selected_geocoding_query: 'Rynek 1 Kraków'
    )
    geocoding_result = GeocodingResult.create!(
      transformed_location: rynek,
      source: 'krakow_msip',
      strategy: 'address_point',
      query: 'Rynek 1 Kraków',
      latitude: 50.061,
      longitude: 19.936,
      confidence: 1.0,
      precision: 'address_point/building',
      selected: true,
      created_at: Time.utc(2026, 1, 1),
      updated_at: Time.utc(2026, 1, 1)
    )
    rynek.update!(selected_geocoding_result_id: geocoding_result.id)

    parcel = TransformedLocation.create!(
      address_1: 'Działka',
      address_kind: 'parcel',
      parcel_number: '1/2',
      parcel_region: '1',
      latitude: 50.07,
      longtitude: 19.94,
      selected_geocoding_source: 'nominatim',
      selected_geocoding_strategy: 'street_fallback',
      selected_geocoding_precision: 'derived/road',
      selected_geocoding_query: 'Działka Kraków'
    )
    rynek_raw = Location.create!(address_1: 'RYNEK', address_2: '1', transformed_location: rynek)
    rynek_raw_latest = Location.create!(address_1: 'RYNEK', address_2: '1 lok. 2', transformed_location: rynek)
    parcel_raw = Location.create!(address_1: 'DZIAŁKA', address_2: '1/2', transformed_location: parcel)

    AlcoholLicense.create!(
      reported_at: Time.utc(2026, 1, 1),
      business_category: detail,
      license_category: category_a,
      business: business,
      location: rynek_raw
    )
    AlcoholLicense.create!(
      reported_at: Time.utc(2026, 2, 1),
      business_category: detail,
      license_category: category_a,
      business: business,
      location: rynek_raw_latest
    )
    AlcoholLicense.create!(
      reported_at: Time.utc(2026, 1, 1),
      business_category: detail,
      license_category: category_a,
      business: business,
      location: parcel_raw
    )
  end

  def clear_dataset_records
    AlcoholLicense.delete_all
    GeocodingResult.delete_all
    Location.delete_all
    TransformedLocation.delete_all
    Business.delete_all
    BusinessCategory.delete_all
    LicenseCategory.delete_all
  end
end
