require 'dataset_export/aggregate_rows'
require 'dataset_export/csv_writer'

module DatasetExport
  module Exporters
    class AggregatesExporter
      def initialize(paths:)
        @paths = paths
        @aggregate_rows = DatasetExport::AggregateRows.new(paths: paths)
      end

      def write
        {
          city_summary_by_report_csv: write_city_summary,
          district_summary_by_report_csv: write_district_summary,
          sim_summary_by_report_csv: write_sim_summary
        }
      end

      def columns
        DatasetExport::AggregateRows::COLUMNS
      end

      private

      attr_reader :paths, :aggregate_rows

      def write_city_summary
        DatasetExport::CsvWriter.write(paths.city_summary_by_report_csv, columns, aggregate_rows.city_rows)
      end

      def write_district_summary
        DatasetExport::CsvWriter.write(paths.district_summary_by_report_csv, columns, aggregate_rows.district_rows)
      end

      def write_sim_summary
        DatasetExport::CsvWriter.write(paths.sim_summary_by_report_csv, columns, aggregate_rows.sim_rows)
      end
    end
  end
end
