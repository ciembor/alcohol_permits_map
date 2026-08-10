require 'dataset_export/csv_writer'
require 'dataset_export/sim_population_rows'

module DatasetExport
  module Exporters
    class SimPopulationsExporter
      def initialize(path:)
        @path = path
        @sim_population_rows = DatasetExport::SimPopulationRows.new
      end

      def write
        DatasetExport::CsvWriter.write(path, columns, sim_population_rows.each)
      end

      def columns
        sim_population_rows.columns
      end

      private

      attr_reader :path, :sim_population_rows
    end
  end
end
