require 'test_helper'
require 'csv'
require 'tmpdir'

class DatasetExport::ReportsExporterTest < ActiveSupport::TestCase
  setup do
    clear_dataset_records
    seed_report_records
  end

  teardown do
    clear_dataset_records
  end

  test 'builds report rows with counts and stable ids' do
    rows = DatasetExport::Exporters::ReportsExporter.new(
      path: '/dev/null',
      source_file_rows: [{ 'reported_at' => @first_report.utc.iso8601 }, { 'reported_at' => @first_report.utc.iso8601 }]
    ).rows

    assert_equal 2, rows.size

    first = rows.first
    assert_equal DatasetExport::StableId.report_id(@first_report), first.fetch('report_id')
    assert_equal '2026-01-01T00:00:00Z', first.fetch('reported_at')
    assert_equal 2, first.fetch('license_count')
    assert_equal 1, first.fetch('geocoded_license_count')
    assert_equal 50.0, first.fetch('geocoded_license_percent')
    assert_equal 1, first.fetch('point_count')
    assert_equal 0, first.fetch('ungrouped_license_count')
    assert_equal 2, first.fetch('source_file_count')
    assert_equal '2025-12-31', first.fetch('population_snapshot_date')
  end

  test 'writes reports csv' do
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'reports.csv')
      count = DatasetExport::Exporters::ReportsExporter.new(path: path).write

      assert_equal 2, count
      csv = CSV.read(path, headers: true, encoding: 'UTF-8')
      assert_equal DatasetExport::Exporters::ReportsExporter::COLUMNS, csv.headers
      assert_equal '2', csv.first.fetch('license_count')
    end
  end

  test 'latest only exports newest report row' do
    rows = DatasetExport::Exporters::ReportsExporter.new(path: '/dev/null', latest_only: true).rows

    assert_equal 1, rows.size
    assert_equal '2026-02-01T00:00:00Z', rows.first.fetch('reported_at')
  end

  private

  def seed_report_records
    @first_report = Time.utc(2026, 1, 1)
    @second_report = Time.utc(2026, 2, 1)

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
    raw = Location.create!(address_1: 'RYNEK', address_2: '1', transformed_location: transformed)

    point = LicensePointGroup.create!(
      reported_at: @first_report,
      latitude: 50.061,
      longitude: 19.936,
      normalized_business_name: 'TEST BUSINESS',
      display_business_name: 'TEST BUSINESS',
      business_names: ['TEST BUSINESS'],
      business_ids: [business.id],
      similarity_floor: 1.0
    )

    AlcoholLicense.create!(
      reported_at: @first_report,
      expires_at: Date.new(2026, 12, 31),
      business_category: detail,
      license_category: category_a,
      business: business,
      location: raw,
      license_point_group: point
    )
    AlcoholLicense.create!(
      reported_at: @first_report,
      business_category: detail,
      license_category: category_a,
      business: business,
      location: Location.create!(address_1: 'BRAK', address_2: '1')
    )
    AlcoholLicense.create!(
      reported_at: @second_report,
      business_category: detail,
      license_category: category_a,
      business: business,
      location: raw
    )

    SimPopulation.create!(
      observed_on: Date.new(2025, 12, 31),
      observed_on_code: 20251231,
      sim_unit_code: '001',
      sim_unit_name: 'Test SIM',
      district_code: 'I',
      district_name: 'Dzielnica I',
      total: 100
    )
  end

  def clear_dataset_records
    AlcoholLicense.delete_all
    LicensePointGroup.delete_all
    Location.delete_all
    TransformedLocation.delete_all
    SimPopulation.delete_all if defined?(SimPopulation)
    Business.delete_all
    BusinessCategory.delete_all
    LicenseCategory.delete_all
  end
end

