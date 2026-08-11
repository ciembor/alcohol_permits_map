require 'csv'
require 'digest'
require 'fileutils'
require 'pathname'
require 'time'

require 'dataset_export/stable_id'

module DatasetExport
  class SourceFilesManifest
    COLUMNS = %w[
      source_file_id
      reported_at
      report_date
      business_category
      license_category
      file_format
      source_origin
      original_filename
      relative_path
      source_url
      retrieved_at
      sha256
      row_count_extracted
      row_count_imported
      notes
    ].freeze

    PDF_REPORT_PREFIX = 'Wersja dokumentu z dnia '.freeze

    def initialize(root: Rails.root, xlsx_glob: 'vendor/data/xlsx/*.xls*', pdf_glob: 'vendor/data/files/**/*.pdf', extracted_csv_glob: 'vendor/data/files/output/*.csv')
      @root = Pathname(root)
      @xlsx_glob = xlsx_glob
      @pdf_glob = pdf_glob
      @extracted_csv_glob = extracted_csv_glob
    end

    def rows
      (spreadsheet_rows + pdf_rows + extracted_csv_rows).sort_by do |row|
        [
          row.fetch('reported_at').to_s,
          row.fetch('business_category').to_s,
          row.fetch('license_category').to_s,
          row.fetch('file_format').to_s,
          row.fetch('relative_path').to_s
        ]
      end
    end

    def write(path)
      FileUtils.mkdir_p(File.dirname(path))

      CSV.open(path, 'w:UTF-8', write_headers: true, headers: COLUMNS) do |csv|
        rows.each { |row| csv << COLUMNS.map { |column| row[column] } }
      end
    end

    private

    attr_reader :root, :xlsx_glob, :pdf_glob, :extracted_csv_glob

    def spreadsheet_rows
      each_path(xlsx_glob).filter_map do |path|
        metadata = spreadsheet_metadata(path)
        next unless metadata

        build_row(path, metadata.merge(
          source_origin: 'historical_spreadsheet_public_information_request',
          row_count_extracted: nil,
          row_count_imported: nil,
          notes: 'source file is linked at report/category level; source row numbers are not part of the public release'
        ))
      end
    end

    def pdf_rows
      each_path(pdf_glob).filter_map do |path|
        metadata = pdf_metadata(path)
        next unless metadata

        build_row(path, metadata.merge(
          source_origin: 'bip_krakow_pdf',
          row_count_extracted: nil,
          row_count_imported: nil,
          notes: 'original PDF; extracted table is listed separately when available'
        ))
      end
    end

    def extracted_csv_rows
      each_path(extracted_csv_glob).filter_map do |path|
        metadata = extracted_csv_metadata(path)
        next unless metadata

        row_count = csv_data_row_count(path)
        build_row(path, metadata.merge(
          source_origin: 'pdf_table_extraction',
          row_count_extracted: row_count,
          row_count_imported: row_count,
          notes: nil
        ))
      end
    end

    def build_row(path, metadata)
      reported_at = metadata.fetch(:reported_at)
      file_format = path.extname.delete_prefix('.').downcase

      {
        'source_file_id' => DatasetExport::StableId.source_file_id(
          reported_at: reported_at,
          business_category: metadata.fetch(:business_category),
          license_category: metadata.fetch(:license_category),
          file_format: file_format
        ),
        'reported_at' => reported_at.utc.iso8601,
        'report_date' => reported_at.to_date.iso8601,
        'business_category' => metadata.fetch(:business_category),
        'license_category' => metadata.fetch(:license_category),
        'file_format' => file_format,
        'source_origin' => metadata.fetch(:source_origin),
        'original_filename' => path.basename.to_s,
        'relative_path' => relative_path(path),
        'source_url' => nil,
        'retrieved_at' => nil,
        'sha256' => Digest::SHA256.file(path).hexdigest,
        'row_count_extracted' => metadata[:row_count_extracted],
        'row_count_imported' => metadata[:row_count_imported],
        'notes' => metadata[:notes]
      }
    end

    def spreadsheet_metadata(path)
      basename = path.basename(path.extname).to_s
      match = basename.match(/\A(?<business_category>detal|gastronomia)_(?<license_category>[ABC])_(?<year>\d{4})_(?<month>\d{2})(?:_(?<day>\d{2}))?\z/)
      return unless match

      {
        reported_at: Time.utc(match[:year].to_i, match[:month].to_i, (match[:day] || '01').to_i),
        business_category: match[:business_category],
        license_category: match[:license_category]
      }
    end

    def pdf_metadata(path)
      parts = relative_path(path).split('/')
      report_dir = parts[-3].to_s
      business_category = parts[-2].to_s
      filename = parts[-1].to_s
      return unless report_dir.start_with?(PDF_REPORT_PREFIX)
      return unless %w[detal gastronomia].include?(business_category)

      license_category = filename[/kategoria\s+([ABC])/, 1]
      return unless license_category

      {
        reported_at: parse_naive_utc(report_dir.delete_prefix(PDF_REPORT_PREFIX)),
        business_category: business_category,
        license_category: license_category
      }
    rescue ArgumentError
      nil
    end

    def extracted_csv_metadata(path)
      basename = path.basename('.csv').to_s
      parts = basename.split(' - ')
      return unless parts.size == 3

      reported_at, business_category, license_category = parts
      return unless %w[detal gastronomia].include?(business_category)
      return unless %w[A B C].include?(license_category)

      {
        reported_at: parse_naive_utc(reported_at),
        business_category: business_category,
        license_category: license_category
      }
    rescue ArgumentError
      nil
    end

    def csv_data_row_count(path)
      CSV.foreach(path, headers: true).count
    end

    def parse_naive_utc(value)
      time = Time.strptime(value.to_s, '%Y-%m-%d %H:%M:%S')
      Time.utc(time.year, time.month, time.day, time.hour, time.min, time.sec)
    end

    def each_path(pattern)
      Dir.glob(root.join(pattern)).map { |path| Pathname(path) }.select(&:file?).sort
    end

    def relative_path(path)
      path.relative_path_from(root).to_s
    end
  end
end
