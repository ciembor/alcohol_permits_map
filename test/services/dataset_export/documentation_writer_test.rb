require 'test_helper'
require 'json'
require 'tmpdir'

class DatasetExport::DocumentationWriterTest < ActiveSupport::TestCase
  setup do
    clear_dataset_records
    seed_report_records
  end

  teardown do
    clear_dataset_records
  end

  test 'writes release documentation from manifest and validation report' do
    Dir.mktmpdir do |dir|
      config = DatasetExport::Config.new(
        version: 'v-test-docs',
        output_dir: dir,
        include_source_files: false,
        latest_only: true
      )
      runner = DatasetExport::Runner.new(config)
      runner.export
      assert runner.validate

      paths = DatasetExport::Paths.new(config)
      DatasetExport::DocumentationWriter.new(paths: paths).write

      assert_includes paths.readme_md.read, 'Quick Start: Python'
      assert_includes paths.readme_md.read, 'Quick Start: R'
      assert_includes paths.readme_md.read, 'Quick Start: QGIS'
      assert_includes paths.codebook_md.read, '`data/tables/reports.csv`'
      assert_includes paths.codebook_md.read, '| `report_id` |'
      assert_includes paths.license.read, 'Creative Commons Attribution 4.0 International'
      assert_includes paths.notice_md.read, 'Reuse Review'
      assert_includes paths.notice_md.read, 'spreadsheet files obtained through access to public information'
      assert_includes paths.notice_md.read, 'Google coordinates and raw Google geocoding responses are not published'
      assert_includes paths.citation_cff.read, 'type: dataset'
      assert_includes paths.validation_report_md.read, 'All validation checks passed.'

      datacite = JSON.parse(paths.datacite_json.read)
      assert_equal 'Dataset', datacite.fetch('types').fetch('resourceTypeGeneral')
      assert_equal 'Maciej Ciemborowicz', datacite.fetch('creators').first.fetch('name')
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
