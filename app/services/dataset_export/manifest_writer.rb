require 'digest'
require 'open3'
require 'pathname'
require 'time'

require 'dataset_export/json_writer'

module DatasetExport
  class ManifestWriter
    def initialize(config:, paths:)
      @config = config
      @paths = paths
      @files = []
    end

    def add(path:, format:, row_count:, description:)
      absolute_path = Pathname(path)
      files << {
        path: absolute_path.relative_path_from(paths.release_root).to_s,
        format: format,
        row_count: row_count,
        description: description,
        bytes: absolute_path.size,
        sha256: Digest::SHA256.file(absolute_path).hexdigest
      }

      files.last
    end

    def write
      DatasetExport::JsonWriter.write(paths.export_manifest_json, payload)
    end

    private

    attr_reader :config, :paths, :files

    def payload
      {
        dataset: {
          name: config.release_name,
          version: config.version,
          generated_at: Time.now.utc.iso8601,
          include_business_names: config.include_business_names,
          include_source_files: config.include_source_files,
          latest_only: config.latest_only
        },
        code: code_metadata,
        files: files
      }
    end

    def code_metadata
      {
        exporter: 'DatasetExport',
        schema_version: 1,
        git_commit_sha: git_commit_sha,
        git_dirty: git_dirty?
      }
    end

    def git_commit_sha
      stdout, _stderr, status = Open3.capture3('git', 'rev-parse', 'HEAD')
      status.success? ? stdout.strip : nil
    rescue Errno::ENOENT
      nil
    end

    def git_dirty?
      stdout, _stderr, status = Open3.capture3('git', 'status', '--porcelain')
      status.success? ? stdout.lines.any? : nil
    rescue Errno::ENOENT
      nil
    end
  end
end
