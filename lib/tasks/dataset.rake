namespace :dataset do
  desc 'Export the dataset release. Env: VERSION=v1.0.0 OUTPUT_DIR=tmp/dataset_release INCLUDE_BUSINESS_NAMES=0 INCLUDE_SOURCE_FILES=1 LATEST_ONLY=0'
  task export: :environment do
    require 'dataset_export/runner'

    result = DatasetExport::Runner.new(DatasetExport::Config.from_env).export
    puts "wrote #{result.fetch(:release_root)}"
    puts "checksummed #{result.fetch(:checksum_count)} files"
  end

  desc 'Validate the dataset release. Env: VERSION=v1.0.0 OUTPUT_DIR=tmp/dataset_release'
  task validate: :environment do
    require 'dataset_export/runner'

    passed = DatasetExport::Runner.new(DatasetExport::Config.from_env).validate
    abort 'dataset validation failed' unless passed

    puts 'dataset validation passed'
  end

  desc 'Package derived release artifacts. Env: VERSION=v1.0.0 OUTPUT_DIR=tmp/dataset_release'
  task package: :environment do
    require 'dataset_export/runner'

    report = DatasetExport::Runner.new(DatasetExport::Config.from_env).package
    puts "package status: #{report.fetch(:status)}"
    puts "parquet files: #{report.fetch(:files, []).size}" if report.key?(:files)
    puts "checksummed #{report.fetch(:checksum_count)} files"
    archive = report.fetch(:archive)
    puts "archive: #{archive.fetch(:archive_name)} (#{archive.fetch(:archive_bytes)} bytes)"
  end

  desc 'Remove generated dataset release directory. Env: VERSION=v1.0.0 OUTPUT_DIR=tmp/dataset_release'
  task clean: :environment do
    require 'dataset_export/config'
    require 'dataset_export/paths'
    require 'fileutils'

    paths = DatasetExport::Paths.new(DatasetExport::Config.from_env)
    FileUtils.rm_rf(paths.release_root)
    puts "removed #{paths.release_root}"
  end

  desc 'Run export and validation for the current dataset release'
  task release: :environment do
    Rake::Task['dataset:export'].invoke
    Rake::Task['dataset:validate'].invoke
    Rake::Task['dataset:package'].invoke
  end

  desc 'Prepare external publication repository. Env: VERSION=v1.0.0 OUTPUT_DIR=tmp/dataset_release PUBLISH_DIR=../krakow-alcohol-licenses'
  task prepare_publication_repo: :environment do
    require 'dataset_export/config'
    require 'dataset_export/paths'
    require 'dataset_export/publication_repository_preparer'

    paths = DatasetExport::Paths.new(DatasetExport::Config.from_env)
    result = DatasetExport::PublicationRepositoryPreparer.new(paths: paths).prepare
    puts "publication repository: #{result.fetch(:destination)}"
    puts "release staging: #{result.fetch(:release_dir)}"
    puts "archive: #{result.fetch(:archive)}"
  end

  desc 'Write source files manifest CSV. Optional env: OUTPUT=tmp/dataset_release/source_files_manifest.csv'
  task source_files_manifest: :environment do
    require 'dataset_export/source_files_manifest'

    output = ENV.fetch('OUTPUT', Rails.root.join('tmp/dataset_release/source_files_manifest.csv').to_s)
    DatasetExport::SourceFilesManifest.new.write(output)
    puts "wrote #{output}"
  end
end
