require 'fileutils'
require 'json'
require 'time'

module DatasetExport
  class PublicationRepositoryPreparer
    DEFAULT_DESTINATION = '/Users/maciej/Projects/krakow-alcohol-licenses'.freeze

    def initialize(paths:, destination: ENV.fetch('PUBLISH_DIR', DEFAULT_DESTINATION))
      @paths = paths
      @destination = Pathname(destination)
    end

    def prepare
      raise "archive does not exist: #{paths.archive_zip}" unless paths.archive_zip.exist?

      FileUtils.mkdir_p(release_dir)
      write_repository_readme
      write_zenodo_notes
      write_gitignore
      copy_release_files

      {
        destination: destination.to_s,
        release_dir: release_dir.to_s,
        archive: publication_archive.to_s,
        copied_files: copied_files.map(&:to_s),
        generated_at: Time.now.utc.iso8601
      }
    end

    private

    attr_reader :paths, :destination

    def release_dir
      destination.join('releases', paths.config.version)
    end

    def publication_archive
      release_dir.join(paths.archive_zip.basename)
    end

    def copied_files
      [
        publication_archive,
        release_dir.join('checksums.txt'),
        release_dir.join('CITATION.cff'),
        release_dir.join('metadata/datacite.json'),
        release_dir.join('metadata/export_manifest.json'),
        release_dir.join('metadata/package_report.json'),
        release_dir.join('metadata/validation_report.json'),
        release_dir.join('metadata/validation_report.md')
      ]
    end

    def copy_release_files
      FileUtils.cp(paths.archive_zip, publication_archive)
      copy_from_release(paths.checksums_txt, release_dir.join('checksums.txt'))
      copy_from_release(paths.citation_cff, release_dir.join('CITATION.cff'))
      copy_from_release(paths.datacite_json, release_dir.join('metadata/datacite.json'))
      copy_from_release(paths.export_manifest_json, release_dir.join('metadata/export_manifest.json'))
      copy_from_release(paths.package_report_json, release_dir.join('metadata/package_report.json'))
      copy_from_release(paths.validation_report_json, release_dir.join('metadata/validation_report.json'))
      copy_from_release(paths.validation_report_md, release_dir.join('metadata/validation_report.md'))
    end

    def copy_from_release(source, target)
      FileUtils.mkdir_p(target.dirname)
      FileUtils.cp(source, target)
    end

    def write_repository_readme
      write_text(destination.join('README.md'), <<~MARKDOWN)
        # Krakow Alcohol Licenses Dataset

        This repository stages public dataset releases for Zenodo publication.

        The processing code is maintained separately in:

        `/Users/maciej/Projects/alcohol_permits_map`

        The dataset record is intended to be published on Zenodo as a dataset with
        DOI. Release archives are stored under `releases/<version>/` before upload.

        Current prepared release:

        - Version: `#{paths.config.version}`
        - Archive: `releases/#{paths.config.version}/#{paths.archive_zip.basename}`
        - Metadata: `releases/#{paths.config.version}/metadata/datacite.json`
        - Citation: `releases/#{paths.config.version}/CITATION.cff`
      MARKDOWN
    end

    def write_zenodo_notes
      write_text(destination.join('ZENODO.md'), <<~MARKDOWN)
        # Zenodo Publication Notes

        Target repository: Zenodo.

        Upload type: dataset.

        Recommended upload file:

        `releases/#{paths.config.version}/#{paths.archive_zip.basename}`

        Metadata source files:

        - `releases/#{paths.config.version}/metadata/datacite.json`
        - `releases/#{paths.config.version}/CITATION.cff`
        - `releases/#{paths.config.version}/metadata/export_manifest.json`
        - `releases/#{paths.config.version}/metadata/validation_report.md`

        Publication workflow:

        1. Create a Zenodo draft upload.
        2. Use resource type `Dataset`.
        3. Reserve a DOI if the DOI should be written back into metadata before final upload.
        4. Upload the ZIP archive.
        5. Fill metadata from DataCite/CITATION files.
        6. Set license to CC BY 4.0.
        7. Preview the record.
        8. Publish after the spreadsheet-source reuse blocker is resolved or after confirming that raw source mirrors are not included.

        Do not upload the processing repository, `.git`, local databases, cache files, or raw source mirrors unless source-file redistribution has been cleared.
      MARKDOWN
    end

    def write_gitignore
      write_text(destination.join('.gitignore'), <<~TEXT)
        .DS_Store
        *.sqlite3
        tmp/
        cache/
      TEXT
    end

    def write_text(path, content)
      FileUtils.mkdir_p(path.dirname)
      File.write(path, content, encoding: 'UTF-8')
    end
  end
end
