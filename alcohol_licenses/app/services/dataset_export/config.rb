require 'pathname'

module DatasetExport
  class Config
    DEFAULT_VERSION = 'v1.0.0'.freeze
    DEFAULT_OUTPUT_DIR = 'tmp/dataset_release'.freeze

    attr_reader :version, :output_dir, :include_business_names, :include_source_files, :latest_only

    def self.from_env(env = ENV)
      new(
        version: env.fetch('VERSION', DEFAULT_VERSION),
        output_dir: env.fetch('OUTPUT_DIR', DEFAULT_OUTPUT_DIR),
        include_business_names: truthy?(env['INCLUDE_BUSINESS_NAMES']),
        include_source_files: env.key?('INCLUDE_SOURCE_FILES') ? truthy?(env['INCLUDE_SOURCE_FILES']) : true,
        latest_only: truthy?(env['LATEST_ONLY'])
      )
    end

    def self.truthy?(value)
      %w[1 true yes y].include?(value.to_s.downcase)
    end

    def initialize(version: DEFAULT_VERSION, output_dir: DEFAULT_OUTPUT_DIR, include_business_names: false, include_source_files: true, latest_only: false)
      @version = version.to_s
      @output_dir = Pathname(output_dir)
      @include_business_names = include_business_names
      @include_source_files = include_source_files
      @latest_only = latest_only
    end

    def release_name
      "krakow-alcohol-licenses-2010-2026-#{version}"
    end
  end
end

