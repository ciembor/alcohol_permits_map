require 'dataset_export/csv_writer'
require 'dataset_export/point_rows'

module DatasetExport
  module Exporters
    class LicensePointsExporter
      def initialize(path:, include_business_names: false, latest_only: false)
        @path = path
        @point_rows = DatasetExport::PointRows.new(
          include_business_names: include_business_names,
          latest_only: latest_only
        )
      end

      def write
        DatasetExport::CsvWriter.write(path, columns, point_rows.each)
      end

      def columns
        point_rows.columns
      end

      private

      attr_reader :path, :point_rows
    end
  end
end
