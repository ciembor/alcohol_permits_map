require 'test_helper'
require 'csv'
require 'tmpdir'

class DatasetExport::AlcoholLicensesExporterTest < ActiveSupport::TestCase
  setup do
    clear_dataset_records
    seed_license_records
  end

  teardown do
    clear_dataset_records
  end

  test 'writes license-level rows without business names by default' do
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'alcohol_licenses.csv')
      count = DatasetExport::Exporters::AlcoholLicensesExporter.new(
        path: path,
        source_file_rows: source_file_rows,
        include_business_names: false
      ).write

      assert_equal 3, count

      csv = CSV.read(path, headers: true, encoding: 'UTF-8')
      assert_equal DatasetExport::LicenseRows::BASE_COLUMNS, csv.headers
      assert_empty csv.headers.grep(/\Ainternal_/)
      refute_includes csv.headers, 'source_row_number'
      refute_includes csv.headers, 'business_name'
      assert_equal 3, csv.map { |row| row.fetch('license_id') }.uniq.size
      assert csv.all? { |row| row.fetch('license_id').present? }
      assert_equal ['source-file-a'], csv.map { |row| row.fetch('source_file_id') }.uniq

      geocoded = csv.find { |row| row.fetch('geocoded') == 'true' }
      assert_equal '50.061', geocoded.fetch('latitude')
      assert_equal '19.936', geocoded.fetch('longitude')
      assert geocoded.fetch('normalized_location_id').start_with?('normalized-location-')
      assert geocoded.fetch('point_id').start_with?('point-')

      ungeocoded = csv.find { |row| row.fetch('geocoded') == 'false' }
      assert_nil ungeocoded['latitude']
      assert_nil ungeocoded['point_id']
    end
  end

  test 'can include business names explicitly' do
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'alcohol_licenses.csv')
      DatasetExport::Exporters::AlcoholLicensesExporter.new(
        path: path,
        source_file_rows: source_file_rows,
        include_business_names: true
      ).write

      csv = CSV.read(path, headers: true, encoding: 'UTF-8')
      assert_includes csv.headers, 'business_name'
      assert_equal 'TEST BUSINESS', csv.first.fetch('business_name')
    end
  end

  test 'latest only limits rows to the newest report' do
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'alcohol_licenses.csv')
      count = DatasetExport::Exporters::AlcoholLicensesExporter.new(
        path: path,
        source_file_rows: source_file_rows,
        latest_only: true
      ).write

      assert_equal 1, count
      csv = CSV.read(path, headers: true, encoding: 'UTF-8')
      assert_equal ['2026-02-01T00:00:00Z'], csv.map { |row| row.fetch('reported_at') }.uniq
    end
  end

  private

  def source_file_rows
    [
      {
        'reported_at' => '2026-01-01T00:00:00Z',
        'business_category' => 'detal',
        'license_category' => 'A',
        'file_format' => 'xlsx',
        'relative_path' => 'vendor/data/xlsx/detal_A_2026_01_01.xlsx',
        'source_file_id' => 'source-file-a'
      },
      {
        'reported_at' => '2026-02-01T00:00:00Z',
        'business_category' => 'detal',
        'license_category' => 'A',
        'file_format' => 'xlsx',
        'relative_path' => 'vendor/data/xlsx/detal_A_2026_02_01.xlsx',
        'source_file_id' => 'source-file-a'
      }
    ]
  end

  def seed_license_records
    report = Time.utc(2026, 1, 1)
    latest_report = Time.utc(2026, 2, 1)
    detail = BusinessCategory.create!(name: 'detal')
    category_a = LicenseCategory.create!(name: 'A', description: 'A description')
    business = Business.create!(name: 'TEST BUSINESS')
    transformed = TransformedLocation.create!(
      address_1: 'Rynek',
      building_number: '1',
      address_kind: 'street_address',
      latitude: 50.061,
      longtitude: 19.936
    )
    raw = Location.create!(address_1: 'RYNEK', address_2: '1', transformed_location: transformed)
    ungeocoded_raw = Location.create!(address_1: 'BRAK', address_2: '1')
    group = LicensePointGroup.create!(
      reported_at: report,
      latitude: 50.061,
      longitude: 19.936,
      normalized_business_name: 'TEST BUSINESS',
      display_business_name: 'TEST BUSINESS',
      business_names: ['TEST BUSINESS'],
      business_ids: [business.id],
      similarity_floor: 1.0
    )

    2.times do
      AlcoholLicense.create!(
        reported_at: report,
        expires_at: Date.new(2026, 12, 31),
        business_category: detail,
        license_category: category_a,
        business: business,
        location: raw,
        license_point_group: group
      )
    end

    AlcoholLicense.create!(
      reported_at: latest_report,
      business_category: detail,
      license_category: category_a,
      business: business,
      location: ungeocoded_raw
    )
  end

  def clear_dataset_records
    AlcoholLicense.delete_all
    LicensePointGroup.delete_all
    Location.delete_all
    TransformedLocation.delete_all
    Business.delete_all
    BusinessCategory.delete_all
    LicenseCategory.delete_all
  end
end
