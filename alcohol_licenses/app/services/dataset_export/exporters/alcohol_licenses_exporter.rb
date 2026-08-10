require 'dataset_export/csv_writer'
require 'dataset_export/license_rows'

module DatasetExport
  module Exporters
    class AlcoholLicensesExporter
      def initialize(path:, source_file_rows: [], include_business_names: false, latest_only: false)
        @path = path
        @license_rows = DatasetExport::LicenseRows.new(
          source_file_rows: source_file_rows,
          include_business_names: include_business_names,
          latest_only: latest_only
        )
      end

      def write
        DatasetExport::CsvWriter.write(path, columns, license_rows.each)
      end

      def columns
        license_rows.columns
      end

      private

      attr_reader :path, :license_rows
    end
  end
end
