require 'dataset_export/csv_writer'
require 'dataset_export/membership_rows'

module DatasetExport
  module Exporters
    class PointMembershipsExporter
      def initialize(path:, latest_only: false)
        @path = path
        @membership_rows = DatasetExport::MembershipRows.new(latest_only: latest_only)
      end

      def write
        DatasetExport::CsvWriter.write(path, columns, membership_rows.each)
      end

      def columns
        membership_rows.columns
      end

      private

      attr_reader :path, :membership_rows
    end
  end
end
