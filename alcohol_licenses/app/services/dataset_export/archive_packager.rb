require 'digest'
require 'fileutils'
require 'zip'

module DatasetExport
  class ArchivePackager
    def initialize(paths:)
      @paths = paths
    end

    def write_zip
      FileUtils.mkdir_p(paths.archive_zip.dirname)
      FileUtils.rm_f(paths.archive_zip)

      entries = release_files
      Zip::File.open(paths.archive_zip, create: true) do |zipfile|
        entries.each do |path|
          zipfile.add(zip_entry_name(path), path.to_s)
        end
      end

      {
        archive_path: paths.archive_zip.to_s,
        archive_name: paths.archive_zip.basename.to_s,
        archive_format: 'zip',
        archive_bytes: paths.archive_zip.size,
        archive_sha256: Digest::SHA256.file(paths.archive_zip).hexdigest,
        archived_file_count: entries.size
      }
    end

    private

    attr_reader :paths

    def release_files
      paths.release_root.find.select(&:file?).sort_by { |path| path.relative_path_from(paths.release_root).to_s }
    end

    def zip_entry_name(path)
      File.join(
        paths.release_root.basename.to_s,
        path.relative_path_from(paths.release_root).to_s
      )
    end
  end
end
