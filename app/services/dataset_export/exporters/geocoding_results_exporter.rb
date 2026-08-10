require 'dataset_export/csv_writer'
require 'dataset_export/geocoding_result_rows'

module DatasetExport
  module Exporters
    class GeocodingResultsExporter
      def initialize(path:, latest_only: false)
        @path = path
        @geocoding_result_rows = DatasetExport::GeocodingResultRows.new(latest_only: latest_only)
      end

      def write
        DatasetExport::CsvWriter.write(path, columns, geocoding_result_rows.each)
      end

      def columns
        geocoding_result_rows.columns
      end

      private

      attr_reader :path, :geocoding_result_rows
    end
  end
end
