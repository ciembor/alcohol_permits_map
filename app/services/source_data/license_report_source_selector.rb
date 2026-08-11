require 'pathname'
require 'time'

module SourceData
  class LicenseReportSourceSelector
    SPREADSHEET_PATTERN = /\A(?<business_category>detal|gastronomia)_(?<license_category>[ABC])_(?<year>\d{4})_(?<month>\d{2})(?:_(?<day>\d{2}))?\z/.freeze
    MINIMUM_CSV_GAP_AFTER_SPREADSHEET_DAYS = 7

    attr_reader :csv_glob, :spreadsheet_glob

    def initialize(csv_glob: 'vendor/data/files/output/*.csv', spreadsheet_glob: 'vendor/data/xlsx/*.xls*')
      @csv_glob = csv_glob
      @spreadsheet_glob = spreadsheet_glob
    end

    def csv_files
      @csv_files ||= Dir.glob(csv_glob).select { |path| csv_metadata(path) }.sort
    end

    def spreadsheet_files
      @spreadsheet_files ||= Dir.glob(spreadsheet_glob).select { |path| spreadsheet_metadata(path) }.sort
    end

    def preferred_csv_files
      last_date = last_spreadsheet_report_date
      return csv_files unless last_date

      csv_files.select do |path|
        csv_metadata(path).fetch(:report_date) >= first_csv_report_date_after_spreadsheets
      end
    end

    def skipped_csv_files
      preferred = preferred_csv_files.to_set
      csv_files.reject { |path| preferred.include?(path) }
    end

    def last_spreadsheet_report_date
      spreadsheet_files.filter_map { |path| spreadsheet_metadata(path)&.fetch(:report_date) }.max
    end

    def first_csv_report_date_after_spreadsheets
      last_spreadsheet_report_date + MINIMUM_CSV_GAP_AFTER_SPREADSHEET_DAYS
    end

    def csv_metadata(path)
      basename = Pathname(path).basename('.csv').to_s
      parts = basename.split(' - ')
      return unless parts.size == 3

      reported_at, business_category, license_category = parts
      return unless %w[detal gastronomia].include?(business_category)
      return unless %w[A B C].include?(license_category)

      parsed_time = Time.strptime(reported_at, '%Y-%m-%d %H:%M:%S')

      {
        reported_at: parsed_time,
        report_date: parsed_time.to_date,
        business_category: business_category,
        license_category: license_category,
        source_format: 'csv'
      }
    rescue ArgumentError
      nil
    end

    def spreadsheet_metadata(path)
      pathname = Pathname(path)
      basename = pathname.basename(pathname.extname).to_s
      match = basename.match(SPREADSHEET_PATTERN)
      return unless match

      year = match[:year].to_i
      month = match[:month].to_i
      day = (match[:day] || '01').to_i

      {
        reported_at: Time.utc(year, month, day),
        report_date: Date.new(year, month, day),
        business_category: match[:business_category],
        license_category: match[:license_category],
        source_format: 'spreadsheet'
      }
    rescue ArgumentError
      nil
    end
  end
end
