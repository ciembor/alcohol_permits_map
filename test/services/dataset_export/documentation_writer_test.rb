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
      assert_includes paths.readme_md.read, 'Analysis Examples'
      assert_includes paths.readme_md.read, 'Kazimierz sales-point change'
      assert_includes paths.codebook_md.read, '`data/tables/reports.csv`'
      assert_includes paths.codebook_md.read, '| `report_id` |'
      assert_includes paths.codebook_md.read, 'Stable pseudonymized business identifier'
      refute_includes paths.codebook_md.read, 'Publication Blockers Before Final DOI'
      assert_includes paths.license.read, 'Creative Commons Attribution 4.0 International'
      assert_includes paths.notice_md.read, 'Reuse Review'
      assert_includes paths.notice_md.read, 'Release Review'
      refute_includes paths.notice_md.read, 'Publication Blockers Before Final DOI'
      assert_includes paths.notice_md.read, 'spreadsheet files obtained through access to public information'
      assert_includes paths.notice_md.read, 'Google coordinates and raw Google geocoding responses are not published'
      citation = paths.citation_cff.read
      assert_includes citation, 'type: dataset'
      assert_includes citation, 'orcid: "https://orcid.org/0009-0009-6877-9931"'
      assert_includes citation, 'doi: "10.5281/zenodo.21895077"'
      assert_includes citation, 'url: "https://doi.org/10.5281/zenodo.21895077"'
      assert_includes paths.validation_report_md.read, 'All validation checks passed.'

      datacite = JSON.parse(paths.datacite_json.read)
      assert_equal 'Dataset', datacite.fetch('types').fetch('resourceTypeGeneral')
      assert_equal '10.5281/zenodo.21895077', datacite.fetch('identifiers').first.fetch('identifier')
      assert_equal 'DOI', datacite.fetch('identifiers').first.fetch('identifierType')
      creator = datacite.fetch('creators').first
      assert_equal 'Maciej Ciemborowicz', creator.fetch('name')
      assert_equal 'https://orcid.org/0009-0009-6877-9931', creator.fetch('nameIdentifiers').first.fetch('nameIdentifier')
      assert_equal 'ORCID', creator.fetch('nameIdentifiers').first.fetch('nameIdentifierScheme')
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
