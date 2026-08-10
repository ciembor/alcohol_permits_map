require 'dataset_export/csv_writer'
require 'dataset_export/geocoding_review_rows'

module DatasetExport
  module Exporters
    class GeocodingReviewsExporter
      def initialize(path:, latest_only: false)
        @path = path
        @geocoding_review_rows = DatasetExport::GeocodingReviewRows.new(latest_only: latest_only)
      end

      def write
        DatasetExport::CsvWriter.write(path, columns, geocoding_review_rows.each)
      end

      def columns
        geocoding_review_rows.columns
      end

      private

      attr_reader :path, :geocoding_review_rows
    end
  end
end
