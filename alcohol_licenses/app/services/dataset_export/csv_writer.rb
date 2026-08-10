require 'csv'
require 'fileutils'

module DatasetExport
  class CsvWriter
    def self.write(path, headers, rows)
      FileUtils.mkdir_p(File.dirname(path))
      count = 0

      CSV.open(path, 'w:UTF-8', write_headers: true, headers: headers) do |csv|
        rows.each do |row|
          csv << headers.map { |header| row.fetch(header) }
          count += 1
        end
      end

      count
    end
  end
end

