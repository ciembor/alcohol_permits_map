require 'test_helper'
require 'csv'
require 'tmpdir'

class DatasetExport::GeocodingResultsExporterTest < ActiveSupport::TestCase
  setup do
    clear_dataset_records
    seed_geocoding_result_records
  end

  teardown do
    clear_dataset_records
  end

  test 'writes non-google geocoding result rows without raw responses' do
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'geocoding_results.csv')
      count = DatasetExport::Exporters::GeocodingResultsExporter.new(path: path).write

      assert_equal 2, count

      csv = CSV.read(path, headers: true, encoding: 'UTF-8')
      assert_equal DatasetExport::GeocodingResultRows::COLUMNS, csv.headers
      refute_includes csv.headers, 'raw_response'
      refute_includes csv.headers, 'created_at'
      assert_equal %w[krakow_msip nominatim], csv.map { |row| row.fetch('source') }.sort
      assert csv.all? { |row| row.fetch('geocoding_result_id').start_with?('geocoding-result-') }

      selected = csv.find { |row| row.fetch('selected') == 'true' }
      assert_equal '50.061', selected.fetch('latitude')
      assert_equal '19.936', selected.fetch('longitude')
      assert_equal 'EPSG:4326', selected.fetch('crs')
      assert selected.fetch('normalized_location_id').start_with?('normalized-location-')
    end
  end

  test 'latest only limits results to locations used in the newest report' do
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'geocoding_results.csv')
      count = DatasetExport::Exporters::GeocodingResultsExporter.new(path: path, latest_only: true).write

      assert_equal 1, count
      csv = CSV.read(path, headers: true, encoding: 'UTF-8')
      assert_equal ['nominatim'], csv.map { |row| row.fetch('source') }
    end
  end

  private

  def seed_geocoding_result_records
    detail = BusinessCategory.create!(name: 'detal')
    category_a = LicenseCategory.create!(name: 'A', description: 'A')
    business = Business.create!(name: 'TEST BUSINESS')
    old_location = TransformedLocation.create!(
      address_1: 'Rynek',
      building_number: '1',
      address_kind: 'street_address'
    )
    latest_location = TransformedLocation.create!(
      address_1: 'Długa',
      building_number: '2',
      address_kind: 'street_address'
    )
    old_raw = Location.create!(address_1: 'RYNEK', address_2: '1', transformed_location: old_location)
    latest_raw = Location.create!(address_1: 'DŁUGA', address_2: '2', transformed_location: latest_location)

    GeocodingResult.create!(
      transformed_location: old_location,
      source: 'krakow_msip',
      strategy: 'address_point',
      query: 'Rynek 1 Kraków',
      latitude: 50.061,
      longitude: 19.936,
      confidence: 1.0,
      precision: 'address_point/building',
      selected: true,
      raw_response: '{"provider":"test"}',
      created_at: Time.utc(2026, 1, 1),
      updated_at: Time.utc(2026, 1, 1)
    )
    GeocodingResult.create!(
      transformed_location: latest_location,
      source: 'nominatim',
      strategy: 'street_fallback',
      query: 'Długa Kraków',
      latitude: nil,
      longitude: nil,
      confidence: 0.2,
      precision: 'derived/road',
      selected: false,
      raw_response: '{"provider":"test"}',
      created_at: Time.utc(2026, 1, 2),
      updated_at: Time.utc(2026, 1, 2)
    )
    GeocodingResult.create!(
      transformed_location: latest_location,
      source: 'google',
      strategy: 'address_point',
      query: 'Długa 2 Kraków',
      latitude: 50.07,
      longitude: 19.94,
      confidence: 1.0,
      precision: 'ROOFTOP/street_address',
      selected: false,
      raw_response: '{"provider":"google"}',
      created_at: Time.utc(2026, 1, 3),
      updated_at: Time.utc(2026, 1, 3)
    )

    AlcoholLicense.create!(
      reported_at: Time.utc(2026, 1, 1),
      business_category: detail,
      license_category: category_a,
      business: business,
      location: old_raw
    )
    AlcoholLicense.create!(
      reported_at: Time.utc(2026, 2, 1),
      business_category: detail,
      license_category: category_a,
      business: business,
      location: latest_raw
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
