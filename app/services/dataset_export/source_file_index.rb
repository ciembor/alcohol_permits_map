module DatasetExport
  class SourceFileIndex
    FORMAT_PRIORITY = {
      'csv' => 0,
      'xlsx' => 1,
      'xls' => 1,
      'pdf' => 2
    }.freeze

    def initialize(source_file_rows)
      @index = source_file_rows
        .group_by { |row| key(row.fetch('reported_at'), row.fetch('business_category'), row.fetch('license_category')) }
        .transform_values { |rows| preferred_source_file_id(rows) }
    end

    def source_file_id(reported_at:, business_category:, license_category:)
      index[key(reported_at.utc.iso8601, business_category, license_category)]
    end

    private

    attr_reader :index

    def key(reported_at, business_category, license_category)
      [reported_at.to_s, business_category.to_s, license_category.to_s]
    end

    def preferred_source_file_id(rows)
      rows
        .sort_by { |row| [FORMAT_PRIORITY.fetch(row.fetch('file_format'), 99), row.fetch('relative_path').to_s] }
        .first
        .fetch('source_file_id')
    end
  end
end

