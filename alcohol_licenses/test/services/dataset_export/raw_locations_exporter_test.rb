require 'test_helper'
require 'csv'
require 'tmpdir'

class DatasetExport::RawLocationsExporterTest < ActiveSupport::TestCase
  setup do
    clear_dataset_records
    seed_location_records
  end

  teardown do
    clear_dataset_records
  end

  test 'writes raw location rows with license counts and report range' do
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'locations_raw.csv')
      count = DatasetExport::Exporters::RawLocationsExporter.new(path: path).write

      assert_equal 2, count

      csv = CSV.read(path, headers: true, encoding: 'UTF-8')
      assert_equal DatasetExport::LocationRows::COLUMNS, csv.headers

      rynek = csv.find { |row| row.fetch('source_address_1') == 'RYNEK' }
      assert rynek.fetch('raw_location_id').start_with?('raw-location-')
      assert rynek.fetch('normalized_location_id').start_with?('normalized-location-')
      assert_equal '2', rynek.fetch('license_count')
      assert_equal '2026-01-01T00:00:00Z', rynek.fetch('first_reported_at')
      assert_equal '2026-02-01T00:00:00Z', rynek.fetch('last_reported_at')

      brak = csv.find { |row| row.fetch('source_address_1') == 'BRAK' }
      assert_nil brak.fetch('normalized_location_id')
      assert_equal '1', brak.fetch('license_count')
    end
  end

  test 'latest only limits counts and locations to the newest report' do
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'locations_raw.csv')
      count = DatasetExport::Exporters::RawLocationsExporter.new(path: path, latest_only: true).write

      assert_equal 1, count
      csv = CSV.read(path, headers: true, encoding: 'UTF-8')
      assert_equal ['RYNEK'], csv.map { |row| row.fetch('source_address_1') }
      assert_equal '1', csv.first.fetch('license_count')
      assert_equal '2026-02-01T00:00:00Z', csv.first.fetch('first_reported_at')
      assert_equal '2026-02-01T00:00:00Z', csv.first.fetch('last_reported_at')
    end
  end

  private

  def seed_location_records
    detail = BusinessCategory.create!(name: 'detal')
    category_a = LicenseCategory.create!(name: 'A', description: 'A')
    business = Business.create!(name: 'TEST BUSINESS')
    transformed = TransformedLocation.create!(
      address_1: 'Rynek',
      building_number: '1',
      address_kind: 'street_address',
      latitude: 50.061,
      longtitude: 19.936
    )
    rynek = Location.create!(address_1: 'RYNEK', address_2: '1', transformed_location: transformed)
    brak = Location.create!(address_1: 'BRAK', address_2: '1')

    AlcoholLicense.create!(
      reported_at: Time.utc(2026, 1, 1),
      business_category: detail,
      license_category: category_a,
      business: business,
      location: rynek
    )
    AlcoholLicense.create!(
      reported_at: Time.utc(2026, 2, 1),
      business_category: detail,
      license_category: category_a,
      business: business,
      location: rynek
    )
    AlcoholLicense.create!(
      reported_at: Time.utc(2026, 1, 1),
      business_category: detail,
      license_category: category_a,
      business: business,
      location: brak
    )
  end

  def clear_dataset_records
    AlcoholLicense.delete_all
    Location.delete_all
    TransformedLocation.delete_all
    Business.delete_all
    BusinessCategory.delete_all
    LicenseCategory.delete_all
  end
end
