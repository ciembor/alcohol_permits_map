require 'dataset_export/csv_writer'
require 'dataset_export/normalized_location_rows'

module DatasetExport
  module Exporters
    class NormalizedLocationsExporter
      def initialize(path:, latest_only: false)
        @path = path
        @normalized_location_rows = DatasetExport::NormalizedLocationRows.new(latest_only: latest_only)
      end

      def write
        DatasetExport::CsvWriter.write(path, columns, normalized_location_rows.each)
      end

      def columns
        normalized_location_rows.columns
      end

      private

      attr_reader :path, :normalized_location_rows
    end
  end
end
