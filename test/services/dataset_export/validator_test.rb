require 'test_helper'
require 'json'
require 'tmpdir'

class DatasetExport::ValidatorTest < ActiveSupport::TestCase
  setup do
    clear_dataset_records
    seed_report_records
  end

  teardown do
    clear_dataset_records
  end

  test 'writes json and markdown validation reports with technical checks' do
    Dir.mktmpdir do |dir|
      config = DatasetExport::Config.new(
        version: 'v-test-validator',
        output_dir: dir,
        include_source_files: false,
        latest_only: true
      )
      DatasetExport::Runner.new(config).export
      paths = DatasetExport::Paths.new(config)

      assert DatasetExport::Validator.new(paths: paths).validate
      assert paths.validation_report_json.exist?
      assert paths.validation_report_md.exist?

      report = JSON.parse(paths.validation_report_json.read)
      assert_equal 'passed', report.fetch('status')
      assert_equal true, report.fetch('passed')
      assert_equal 0, report.fetch('summary').fetch('failed_checks')
      assert_equal report.fetch('checks').size, report.fetch('summary').fetch('total_checks')
      check_names = report.fetch('checks').map { |check| check.fetch('name') }
      assert_includes check_names, 'data_tables_alcohol_licenses_csv_utf8'
      assert_includes check_names, 'data_tables_alcohol_licenses_csv_unique_headers'
      assert_includes check_names, 'data_tables_alcohol_licenses_csv_iso_dates'
      assert_includes check_names, 'data_tables_alcohol_licenses_csv_no_local_absolute_paths'
      assert_includes paths.validation_report_md.read, 'All validation checks passed.'
    end
  end

  private

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
