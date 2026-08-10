require 'dataset_export/address_correction_rows'
require 'dataset_export/csv_writer'

module DatasetExport
  module Exporters
    class AddressCorrectionsExporter
      def initialize(path:, latest_only: false)
        @path = path
        @address_correction_rows = DatasetExport::AddressCorrectionRows.new(latest_only: latest_only)
      end

      def write
        DatasetExport::CsvWriter.write(path, columns, address_correction_rows.each)
      end

      def columns
        address_correction_rows.columns
      end

      private

      attr_reader :path, :address_correction_rows
    end
  end
end
