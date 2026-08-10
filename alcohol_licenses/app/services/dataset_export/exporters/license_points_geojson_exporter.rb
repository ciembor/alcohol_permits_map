require 'csv'

require 'dataset_export/geospatial_writer'

module DatasetExport
  module Exporters
    class LicensePointsGeojsonExporter
      def initialize(paths:)
        @paths = paths
      end

      def write
        DatasetExport::GeospatialWriter.write_point_geojson(
          path: paths.license_points_latest_geojson,
          rows: latest_point_rows
        )
      end

      private

      attr_reader :paths

      def latest_point_rows
        latest_reported_at = latest_report.fetch('reported_at')

        Enumerator.new do |yielder|
          CSV.foreach(paths.license_points_csv, headers: true, encoding: 'UTF-8') do |row|
            yielder << row if row.fetch('reported_at') == latest_reported_at
          end
        end
      end

      def latest_report
        CSV.read(paths.reports_csv, headers: true, encoding: 'UTF-8')[-1]
      end
    end
  end
end
