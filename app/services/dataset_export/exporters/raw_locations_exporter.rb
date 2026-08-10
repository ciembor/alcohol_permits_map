require 'dataset_export/csv_writer'
require 'dataset_export/location_rows'

module DatasetExport
  module Exporters
    class RawLocationsExporter
      def initialize(path:, latest_only: false)
        @path = path
        @location_rows = DatasetExport::LocationRows.new(latest_only: latest_only)
      end

      def write
        DatasetExport::CsvWriter.write(path, columns, location_rows.each)
      end

      def columns
        location_rows.columns
      end

      private

      attr_reader :path, :location_rows
    end
  end
end
