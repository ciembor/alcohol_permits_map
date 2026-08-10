require 'csv'
require 'fileutils'
require 'json'
require 'open3'
require 'pathname'
require 'time'

require 'dataset_export/json_writer'

module DatasetExport
  class ParquetPackager
    PYARROW_SCRIPT = <<~PYTHON.freeze
      import json
      import sys
      from pathlib import Path

      import pyarrow.csv as csv
      import pyarrow.parquet as pq

      jobs = json.loads(sys.argv[1])
      results = []

      for job in jobs:
          source_path = Path(job["source_path"])
          output_path = Path(job["output_path"])
          output_path.parent.mkdir(parents=True, exist_ok=True)
          table = csv.read_csv(source_path)
          pq.write_table(table, output_path, compression="zstd")
          parquet_file = pq.ParquetFile(output_path)
          results.append({
              "source_path": str(source_path),
              "output_path": str(output_path),
              "row_count": parquet_file.metadata.num_rows,
              "schema": {
                  field.name: str(field.type)
                  for field in parquet_file.schema_arrow
              }
          })

      print(json.dumps(results, ensure_ascii=False))
    PYTHON

    def initialize(paths:, python_executable: ENV.fetch('PYTHON', 'python3'))
      @paths = paths
      @python_executable = python_executable
    end

    def package
      tools = detect_tools
      unless tools.fetch(:pyarrow)
        report = skipped_report(tools)
        write_report(report)
        return report
      end

      FileUtils.mkdir_p(paths.parquet_dir)
      jobs = csv_manifest_entries.map { |entry| job_for(entry) }
      results = convert_with_pyarrow(jobs)
      files = files_from_results(results)
      row_count_mismatches = files.reject { |file| file.fetch(:row_count_matches) }
      report = {
        generated_at: Time.now.utc.iso8601,
        status: row_count_mismatches.empty? ? 'passed' : 'failed',
        parquet_generated: true,
        tool: {
          name: 'pyarrow',
          version: tools.fetch(:pyarrow_version),
          python_executable: python_executable
        },
        files: files,
        errors: row_count_mismatches.map { |file| "row_count_mismatch:#{file.fetch(:parquet_path)}" }
      }
      write_report(report)
      report
    end

    private

    attr_reader :paths, :python_executable

    def detect_tools
      pyarrow_stdout, _pyarrow_stderr, pyarrow_status = Open3.capture3(
        python_executable,
        '-c',
        'import pyarrow; print(pyarrow.__version__)'
      )

      {
        pyarrow: pyarrow_status.success?,
        pyarrow_version: pyarrow_status.success? ? pyarrow_stdout.strip : nil,
        duckdb_cli: duckdb_available?,
        ruby_parquet_gem: ruby_parquet_gem_available?
      }
    rescue Errno::ENOENT, SystemCallError
      {
        pyarrow: false,
        pyarrow_version: nil,
        duckdb_cli: duckdb_available?,
        ruby_parquet_gem: ruby_parquet_gem_available?
      }
    end

    def duckdb_available?
      _stdout, _stderr, status = Open3.capture3('duckdb', '--version')
      status.success?
    rescue Errno::ENOENT, SystemCallError
      false
    end

    def ruby_parquet_gem_available?
      Gem::Specification.find_all_by_name('parquet').any? ||
        Gem::Specification.find_all_by_name('red-parquet').any?
    end

    def skipped_report(tools)
      {
        generated_at: Time.now.utc.iso8601,
        status: 'skipped',
        parquet_generated: false,
        tools: tools,
        reason: 'Python pyarrow is not available; CSV remains the source of truth.'
      }
    end

    def csv_manifest_entries
      manifest.fetch('files').select { |file| file.fetch('format') == 'csv' }
    end

    def manifest
      JSON.parse(paths.export_manifest_json.read)
    end

    def job_for(entry)
      relative_path = entry.fetch('path')
      {
        'source_path' => paths.release_root.join(relative_path).to_s,
        'output_path' => paths.parquet_dir.join(relative_path.sub(%r{\Adata/}, '').sub(/\.csv\z/, '.parquet')).to_s,
        'manifest_path' => relative_path,
        'expected_row_count' => entry.fetch('row_count')
      }
    end

    def convert_with_pyarrow(jobs)
      stdout, stderr, status = Open3.capture3(python_executable, '-c', PYARROW_SCRIPT, JSON.generate(jobs))
      raise "pyarrow parquet conversion failed: #{stderr}" unless status.success?

      JSON.parse(stdout)
    end

    def files_from_results(results)
      results.map do |result|
        source_path = Pathname(result.fetch('source_path'))
        parquet_path = Pathname(result.fetch('output_path'))
        manifest_entry = manifest_entry_for(source_path)
        expected_row_count = manifest_entry.fetch('row_count')
        actual_row_count = result.fetch('row_count')

        {
          source_path: manifest_entry.fetch('path'),
          parquet_path: parquet_path.relative_path_from(paths.release_root).to_s,
          expected_row_count: expected_row_count,
          row_count: actual_row_count,
          row_count_matches: actual_row_count == expected_row_count,
          schema: result.fetch('schema')
        }
      end
    end

    def manifest_entry_for(source_path)
      csv_manifest_entries.find do |entry|
        paths.release_root.join(entry.fetch('path')) == source_path
      end
    end

    def write_report(report)
      DatasetExport::JsonWriter.write(paths.package_report_json, report)
    end
  end
end
