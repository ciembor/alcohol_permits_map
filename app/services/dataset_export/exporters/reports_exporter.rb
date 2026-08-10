require 'dataset_export/csv_writer'
require 'dataset_export/stable_id'

module DatasetExport
  module Exporters
    class ReportsExporter
      COLUMNS = %w[
        report_id
        reported_at
        report_date
        license_count
        geocoded_license_count
        geocoded_license_percent
        point_count
        ungrouped_license_count
        source_file_count
        population_snapshot_date
        notes
      ].freeze

      def initialize(path:, source_file_rows: [], latest_only: false)
        @path = path
        @source_file_counts = source_file_rows.each_with_object(Hash.new(0)) do |row, memo|
          memo[row.fetch('reported_at')] += 1
        end
        @latest_only = latest_only
      end

      def write
        DatasetExport::CsvWriter.write(path, COLUMNS, rows)
      end

      def rows
        report_times.map { |reported_at| row_for_report(reported_at) }
      end

      private

      attr_reader :path, :source_file_counts, :latest_only

      def report_times
        scope = AlcoholLicense.where.not(reported_at: nil).distinct.order(:reported_at)
        times = scope.pluck(:reported_at)
        latest_only ? times.last(1) : times
      end

      def row_for_report(reported_at)
        license_count = AlcoholLicense.where(reported_at: reported_at).count
        geocoded_license_count = AlcoholLicense
          .joins(location: :transformed_location)
          .where(reported_at: reported_at)
          .where.not(transformed_locations: { latitude: nil, longtitude: nil })
          .count
        point_count = point_count_for_report(reported_at)

        {
          'report_id' => DatasetExport::StableId.report_id(reported_at),
          'reported_at' => reported_at.utc.iso8601,
          'report_date' => reported_at.to_date.iso8601,
          'license_count' => license_count,
          'geocoded_license_count' => geocoded_license_count,
          'geocoded_license_percent' => percentage(geocoded_license_count, license_count),
          'point_count' => point_count,
          'ungrouped_license_count' => [geocoded_license_count - grouped_license_count_for_report(reported_at), 0].max,
          'source_file_count' => source_file_counts.fetch(reported_at.utc.iso8601, 0),
          'population_snapshot_date' => population_snapshot_date(reported_at),
          'notes' => nil
        }
      end

      def point_count_for_report(reported_at)
        LicensePointGroup.where(reported_at: reported_at).count + fallback_point_count_for_report(reported_at)
      end

      def fallback_point_count_for_report(reported_at)
        AlcoholLicense
          .joins(location: :transformed_location)
          .where(reported_at: reported_at, license_point_group_id: nil)
          .where.not(transformed_locations: { latitude: nil, longtitude: nil })
          .group(
            'alcohol_licenses.reported_at',
            'alcohol_licenses.business_id',
            'alcohol_licenses.location_id',
            'transformed_locations.latitude',
            'transformed_locations.longtitude'
          )
          .count
          .size
      end

      def grouped_license_count_for_report(reported_at)
        AlcoholLicense.where(reported_at: reported_at).where.not(license_point_group_id: nil).count
      end

      def population_snapshot_date(reported_at)
        SimPopulation
          .where('observed_on <= ?', reported_at.to_date)
          .maximum(:observed_on)
          &.iso8601
      end

      def percentage(count, total)
        return 0 if total.to_i.zero?

        (count * 100.0 / total).round(2)
      end
    end
  end
end
