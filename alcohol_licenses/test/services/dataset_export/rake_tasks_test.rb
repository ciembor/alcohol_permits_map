require 'test_helper'
require 'csv'
require 'rake'
require 'stringio'
require 'tmpdir'

class DatasetExport::RakeTasksTest < ActiveSupport::TestCase
  setup do
    Rails.application.load_tasks unless Rake::Task.task_defined?('dataset:export')
    clear_dataset_records
    seed_report_records
  end

  teardown do
    clear_dataset_records
    %w[VERSION OUTPUT_DIR INCLUDE_SOURCE_FILES INCLUDE_BUSINESS_NAMES LATEST_ONLY PUBLISH_DIR].each { |key| ENV.delete(key) }
    Rake::Task['dataset:export'].reenable
    Rake::Task['dataset:validate'].reenable
    Rake::Task['dataset:package'].reenable
    Rake::Task['dataset:release'].reenable
    Rake::Task['dataset:prepare_publication_repo'].reenable
  end

  test 'dataset export task smoke with latest only' do
    Dir.mktmpdir do |dir|
      with_dataset_env(dir, version: 'v-rake-latest', latest_only: '1') do
        silence_stdout { Rake::Task['dataset:export'].invoke }
      end

      paths = DatasetExport::Paths.new(config_for(dir, 'v-rake-latest'))
      assert paths.reports_csv.exist?
      assert_equal 1, CSV.read(paths.reports_csv, headers: true, encoding: 'UTF-8').size
      assert paths.license_points_latest_geojson.exist?
    end
  end

  test 'dataset export task smoke with full small fixture' do
    Dir.mktmpdir do |dir|
      with_dataset_env(dir, version: 'v-rake-full', latest_only: '0') do
        silence_stdout { Rake::Task['dataset:export'].invoke }
      end

      paths = DatasetExport::Paths.new(config_for(dir, 'v-rake-full'))
      assert paths.reports_csv.exist?
      assert_equal 2, CSV.read(paths.reports_csv, headers: true, encoding: 'UTF-8').size
      assert paths.export_manifest_json.exist?
      assert paths.checksums_txt.exist?
    end
  end

  test 'dataset release task runs export validation and package' do
    Dir.mktmpdir do |dir|
      with_dataset_env(dir, version: 'v-rake-release', latest_only: '1') do
        silence_stdout { Rake::Task['dataset:release'].invoke }
      end

      paths = DatasetExport::Paths.new(config_for(dir, 'v-rake-release'))
      assert paths.validation_report_json.exist?
      assert paths.package_report_json.exist?
      assert paths.archive_zip.exist?
    end
  end

  test 'dataset prepare publication repository task stages release outside export directory' do
    Dir.mktmpdir do |dir|
      Dir.mktmpdir do |publish_dir|
        with_dataset_env(dir, version: 'v-rake-publication', latest_only: '1') do
          silence_stdout { Rake::Task['dataset:release'].invoke }
          ENV['PUBLISH_DIR'] = publish_dir
          silence_stdout { Rake::Task['dataset:prepare_publication_repo'].invoke }
        end

        staged_release = Pathname(publish_dir).join('releases/v-rake-publication')
        assert staged_release.join('krakow-alcohol-licenses-2010-2026-v-rake-publication.zip').exist?
        assert staged_release.join('metadata/datacite.json').exist?
        assert Pathname(publish_dir).join('ZENODO.md').exist?
      end
    end
  end

  private

  def with_dataset_env(dir, version:, latest_only:)
    ENV['VERSION'] = version
    ENV['OUTPUT_DIR'] = dir
    ENV['INCLUDE_SOURCE_FILES'] = '0'
    ENV['INCLUDE_BUSINESS_NAMES'] = '0'
    ENV['LATEST_ONLY'] = latest_only
    yield
  ensure
    Rake::Task['dataset:export'].reenable
  end

  def config_for(dir, version)
    DatasetExport::Config.new(
      version: version,
      output_dir: dir,
      include_source_files: false,
      latest_only: false
    )
  end

  def silence_stdout
    original_stdout = $stdout
    $stdout = StringIO.new
    yield
  ensure
    $stdout = original_stdout
  end

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
