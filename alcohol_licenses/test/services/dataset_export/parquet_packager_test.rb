require 'test_helper'
require 'json'
require 'tmpdir'

class DatasetExport::ParquetPackagerTest < ActiveSupport::TestCase
  setup do
    clear_dataset_records
    seed_report_records
  end

  teardown do
    clear_dataset_records
  end

  test 'writes skipped package report when pyarrow is unavailable' do
    Dir.mktmpdir do |dir|
      config = export_minimal_release(dir)
      paths = DatasetExport::Paths.new(config)

      report = DatasetExport::ParquetPackager.new(
        paths: paths,
        python_executable: '/missing/python3'
      ).package

      assert_equal 'skipped', report.fetch(:status)
      assert_equal false, report.fetch(:parquet_generated)
      assert paths.package_report_json.exist?

      persisted = JSON.parse(paths.package_report_json.read)
      assert_equal 'skipped', persisted.fetch('status')
    end
  end

  test 'packages csv tables as parquet when pyarrow is available' do
    skip 'pyarrow is not available' unless pyarrow_available?

    Dir.mktmpdir do |dir|
      config = export_minimal_release(dir)
      paths = DatasetExport::Paths.new(config)

      report = DatasetExport::ParquetPackager.new(paths: paths).package

      assert_equal 'passed', report.fetch(:status)
      assert_equal true, report.fetch(:parquet_generated)
      assert paths.package_report_json.exist?
      assert paths.parquet_dir.join('tables/reports.parquet').exist?
      assert paths.parquet_dir.join('tables/alcohol_licenses.parquet').exist?
      assert paths.parquet_dir.join('aggregates/city_summary_by_report.parquet').exist?
      assert report.fetch(:files).all? { |file| file.fetch(:row_count_matches) }
    end
  end

  private

  def export_minimal_release(dir)
    config = DatasetExport::Config.new(
      version: 'v-test-parquet',
      output_dir: dir,
      include_source_files: false,
      latest_only: true
    )
    DatasetExport::Runner.new(config).export
    config
  end

  def pyarrow_available?
    system('python3', '-c', 'import pyarrow', out: File::NULL, err: File::NULL)
  end

  def seed_report_records
    detail = BusinessCategory.create!(name: 'detal')
    category_a = LicenseCategory.create!(name: 'A', description: 'A')
    business = Business.create!(name: 'TEST BUSINESS')
    raw = Location.create!(address_1: 'RYNEK', address_2: '1')

    AlcoholLicense.create!(
      reported_at: Time.utc(2026, 2, 1),
      business_category: detail,
      license_category: category_a,
      business: business,
      location: raw
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
