require 'test_helper'
require 'csv'
require 'json'
require 'tmpdir'
require 'zip'

class DatasetExport::RunnerTest < ActiveSupport::TestCase
  setup do
    clear_dataset_records
    seed_report_records
  end

  teardown do
    clear_dataset_records
  end

  test 'exports a minimal release and validates it' do
    Dir.mktmpdir do |dir|
      config = DatasetExport::Config.new(
        version: 'v-test',
        output_dir: dir,
        include_source_files: false,
        latest_only: true
      )
      runner = DatasetExport::Runner.new(config)

      result = runner.export
      paths = DatasetExport::Paths.new(config)

      assert_equal paths.release_root.to_s, result.fetch(:release_root)
      assert paths.reports_csv.exist?
      assert paths.export_manifest_json.exist?
      assert paths.checksums_txt.exist?
      assert runner.validate
      assert paths.validation_report_json.exist?
      assert paths.validation_report_md.exist?
      package_report = runner.package
      assert_includes %w[passed skipped], package_report.fetch(:status)
      assert paths.archive_zip.exist?
      assert_equal 'krakow-alcohol-licenses-2010-2026-v-test.zip', package_report.fetch(:archive).fetch(:archive_name)
      assert paths.package_report_json.exist?
      assert paths.readme_md.exist?
      assert paths.codebook_md.exist?
      assert paths.license.exist?
      assert paths.notice_md.exist?
      assert paths.citation_cff.exist?
      assert paths.datacite_json.exist?
      assert paths.validation_report_md.exist?
      assert_includes paths.checksums_txt.read, 'metadata/package_report.json'
      assert_includes paths.checksums_txt.read, 'README.md'
      assert_includes paths.checksums_txt.read, 'LICENSE'
      archive_entries = Zip::File.open(paths.archive_zip) { |zip| zip.map(&:name) }
      assert_includes archive_entries, 'krakow-alcohol-licenses-2010-2026-v-test/README.md'
      assert_includes archive_entries, 'krakow-alcohol-licenses-2010-2026-v-test/checksums.txt'
      assert_empty archive_entries.grep(%r{(^|/)\.git/|(^|/)tmp/|development\.sqlite3|test\.sqlite3})

      reports = CSV.read(paths.reports_csv, headers: true, encoding: 'UTF-8')
      assert_equal 1, reports.size
      assert_equal '2026-02-01T00:00:00Z', reports.first.fetch('reported_at')

      licenses = CSV.read(paths.alcohol_licenses_csv, headers: true, encoding: 'UTF-8')
      normalized_locations = CSV.read(paths.locations_normalized_csv, headers: true, encoding: 'UTF-8')
      geocoding_results = CSV.read(paths.geocoding_results_csv, headers: true, encoding: 'UTF-8')
      assert_includes licenses.headers, 'longitude'
      refute_includes licenses.headers, 'longtitude'
      assert_empty normalized_locations.headers.grep(/google/i)
      refute_includes geocoding_results.headers, 'raw_response'
      assert_empty geocoding_results.select { |row| row.fetch('source') == 'google' }

      manifest = JSON.parse(paths.export_manifest_json.read)
      assert_equal 'krakow-alcohol-licenses-2010-2026-v-test', manifest.fetch('dataset').fetch('name')
      assert_equal 'DatasetExport', manifest.fetch('code').fetch('exporter')
      assert_equal 1, manifest.fetch('code').fetch('schema_version')
      assert manifest.fetch('code').key?('git_commit_sha')
      assert manifest.fetch('code').key?('git_dirty')
      assert_equal [
        'data/tables/reports.csv',
        'data/tables/alcohol_licenses.csv',
        'data/tables/license_points.csv',
        'data/tables/point_memberships.csv',
        'data/tables/locations_raw.csv',
        'data/tables/locations_normalized.csv',
        'data/tables/address_corrections.csv',
        'data/tables/geocoding_results.csv',
        'data/tables/geocoding_reviews.csv',
        'data/tables/sim_populations.csv',
        'data/geospatial/sim_units.geojson',
        'data/aggregates/city_summary_by_report.csv',
        'data/aggregates/district_summary_by_report.csv',
        'data/aggregates/sim_summary_by_report.csv',
        'data/geospatial/license_points_latest.geojson'
      ], manifest.fetch('files').map { |file| file.fetch('path') }
    end
  end

  test 'validates full multi-report export boundaries' do
    Dir.mktmpdir do |dir|
      config = DatasetExport::Config.new(
        version: 'v-test-full',
        output_dir: dir,
        include_source_files: false,
        latest_only: false
      )
      runner = DatasetExport::Runner.new(config)

      runner.export

      assert runner.validate

      paths = DatasetExport::Paths.new(config)
      report = JSON.parse(paths.validation_report_json.read)
      check_names = report.fetch('checks').map { |check| check.fetch('name') }
      assert_includes check_names, 'reports_csv_first_report'
      assert_includes check_names, 'reports_csv_last_report'
    end
  end

  private

  def seed_report_records
    detail = BusinessCategory.create!(name: 'detal')
    category_a = LicenseCategory.create!(name: 'A', description: 'A')
    business = Business.create!(name: 'TEST BUSINESS')
    raw = Location.create!(address_1: 'RYNEK', address_2: '1')

    AlcoholLicense.create!(
      reported_at: Time.utc(2026, 1, 1),
      business_category: detail,
      license_category: category_a,
      business: business,
      location: raw
    )
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
