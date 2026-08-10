require 'test_helper'
require 'tmpdir'

class DatasetExport::PublicationRepositoryPreparerTest < ActiveSupport::TestCase
  test 'stages release archive and metadata in an external publication repository layout' do
    Dir.mktmpdir do |output_dir|
      Dir.mktmpdir do |publish_dir|
        config = DatasetExport::Config.new(version: 'v-test-publication', output_dir: output_dir)
        paths = DatasetExport::Paths.new(config)
        paths.mkdirs
        File.write(paths.archive_zip, "zip\n")
        File.write(paths.checksums_txt, "checksum\n")
        File.write(paths.citation_cff, "cff\n")
        DatasetExport::JsonWriter.write(paths.datacite_json, { title: 'DataCite' })
        DatasetExport::JsonWriter.write(paths.export_manifest_json, { title: 'Manifest' })
        DatasetExport::JsonWriter.write(paths.package_report_json, { status: 'passed' })
        DatasetExport::JsonWriter.write(paths.validation_report_json, { passed: true })
        File.write(paths.validation_report_md, "validation\n")

        result = DatasetExport::PublicationRepositoryPreparer.new(
          paths: paths,
          destination: publish_dir
        ).prepare

        release_dir = Pathname(publish_dir).join('releases/v-test-publication')
        assert_equal publish_dir, result.fetch(:destination)
        assert release_dir.join('krakow-alcohol-licenses-2010-2026-v-test-publication.zip').exist?
        assert release_dir.join('checksums.txt').exist?
        assert release_dir.join('CITATION.cff').exist?
        assert release_dir.join('metadata/datacite.json').exist?
        assert release_dir.join('metadata/export_manifest.json').exist?
        assert release_dir.join('metadata/package_report.json').exist?
        assert release_dir.join('metadata/validation_report.md').exist?
        assert Pathname(publish_dir).join('README.md').exist?
        assert Pathname(publish_dir).join('ZENODO.md').exist?
        assert_includes Pathname(publish_dir).join('ZENODO.md').read, 'Target repository: Zenodo'
      end
    end
  end
end
