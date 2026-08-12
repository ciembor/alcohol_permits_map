require 'csv'
require 'date'
require 'fileutils'
require 'json'
require 'set'
require 'time'

require 'dataset_export/exporters/address_corrections_exporter'
require 'dataset_export/exporters/aggregates_exporter'
require 'dataset_export/exporters/alcohol_licenses_exporter'
require 'dataset_export/exporters/geocoding_results_exporter'
require 'dataset_export/exporters/geocoding_reviews_exporter'
require 'dataset_export/exporters/license_points_geojson_exporter'
require 'dataset_export/exporters/license_points_exporter'
require 'dataset_export/exporters/normalized_locations_exporter'
require 'dataset_export/exporters/point_memberships_exporter'
require 'dataset_export/exporters/raw_locations_exporter'
require 'dataset_export/exporters/reports_exporter'
require 'dataset_export/exporters/sim_populations_exporter'
require 'dataset_export/exporters/sim_units_exporter'
require 'dataset_export/json_writer'
require 'dataset_export/stable_id'
require_dependency 'sim/units'

module DatasetExport
  class Validator
    def initialize(paths:)
      @paths = paths
      @errors = []
      @checks = []
    end

    def validate
      validate_csv_technical_checks
      validate_reports_csv if paths.reports_csv.exist?
      validate_alcohol_licenses_csv if paths.alcohol_licenses_csv.exist?
      validate_license_points_csv if paths.license_points_csv.exist?
      validate_point_memberships_csv if paths.point_memberships_csv.exist?
      validate_locations_raw_csv if paths.locations_raw_csv.exist?
      validate_locations_normalized_csv if paths.locations_normalized_csv.exist?
      validate_address_corrections_csv if paths.address_corrections_csv.exist?
      validate_geocoding_results_csv if paths.geocoding_results_csv.exist?
      validate_geocoding_reviews_csv if paths.geocoding_reviews_csv.exist?
      validate_sim_populations_csv if paths.sim_populations_csv.exist?
      validate_sim_units_geojson if paths.sim_units_geojson.exist?
      validate_aggregates_csv if aggregate_paths_exist?
      validate_license_points_latest_geojson if paths.license_points_latest_geojson.exist?
      validate_license_point_relations if paths.alcohol_licenses_csv.exist? && paths.license_points_csv.exist?
      validate_point_membership_relations if paths.alcohol_licenses_csv.exist? && paths.license_points_csv.exist? && paths.point_memberships_csv.exist?
      validate_raw_location_relations if paths.alcohol_licenses_csv.exist? && paths.locations_raw_csv.exist?
      validate_address_correction_relations if paths.address_corrections_csv.exist? && paths.locations_raw_csv.exist?
      validate_geocoding_result_relations if paths.geocoding_results_csv.exist? && paths.locations_normalized_csv.exist?
      validate_geocoding_review_relations if paths.geocoding_reviews_csv.exist? && paths.locations_normalized_csv.exist?
      write_report
      errors.empty?
    end

    private

    attr_reader :paths, :errors, :checks

    def validate_csv_technical_checks
      csv_paths.each do |path|
        next unless path.exist?

        validate_csv_encoding(path)
        validate_csv_headers_unique(path)
        validate_csv_dates(path)
        validate_csv_coordinates(path)
        validate_csv_json_fields(path)
        validate_csv_no_local_absolute_paths(path)
        validate_csv_no_internal_columns(path)
      end
    end

    def csv_paths
      [
        paths.reports_csv,
        paths.alcohol_licenses_csv,
        paths.license_points_csv,
        paths.point_memberships_csv,
        paths.locations_raw_csv,
        paths.locations_normalized_csv,
        paths.address_corrections_csv,
        paths.geocoding_results_csv,
        paths.geocoding_reviews_csv,
        paths.sim_populations_csv,
        paths.source_files_manifest_csv,
        paths.city_summary_by_report_csv,
        paths.district_summary_by_report_csv,
        paths.sim_summary_by_report_csv
      ]
    end

    def check_prefix_for(path)
      path.relative_path_from(paths.release_root).to_s.tr('/.', '_')
    end

    def validate_csv_encoding(path)
      path.read(encoding: 'UTF-8')
      add_check("#{check_prefix_for(path)}_utf8", true, expected: 'valid UTF-8', actual: 'valid UTF-8')
    rescue Encoding::InvalidByteSequenceError, Encoding::UndefinedConversionError, ArgumentError => error
      add_check("#{check_prefix_for(path)}_utf8", false, expected: 'valid UTF-8', actual: error.message)
    end

    def validate_csv_headers_unique(path)
      headers = CSV.open(path, 'r:UTF-8', &:readline)
      duplicates = headers.tally.select { |_header, count| count > 1 }.keys
      add_check("#{check_prefix_for(path)}_unique_headers", duplicates.empty?, expected: [], actual: duplicates)
    rescue CSV::MalformedCSVError, ArgumentError => error
      add_check("#{check_prefix_for(path)}_unique_headers", false, expected: 'parseable CSV headers', actual: error.message)
    end

    def validate_csv_dates(path)
      invalid_values = []
      CSV.foreach(path, headers: true, encoding: 'UTF-8') do |row|
        date_columns(row.headers).each do |column|
          value = row[column]
          next if value.blank?

          invalid_values << "#{column}=#{value}" unless iso_date_or_time?(value)
          break if invalid_values.size >= 10
        end
        break if invalid_values.size >= 10
      end

      add_check("#{check_prefix_for(path)}_iso_dates", invalid_values.empty?, expected: [], actual: invalid_values)
    end

    def date_columns(headers)
      headers.select { |header| header.end_with?('_at') || header.end_with?('_date') || header.end_with?('_on') || header == 'expires_at' }
    end

    def iso_date_or_time?(value)
      return true if value.match?(/\A\d{4}-\d{2}-\d{2}\z/)
      return true if value.match?(/\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/)

      false
    end

    def validate_csv_coordinates(path)
      invalid_values = []
      CSV.foreach(path, headers: true, encoding: 'UTF-8') do |row|
        %w[latitude longitude].each do |column|
          next unless row.headers.include?(column)

          value = row[column]
          next if value.blank?

          Float(value)
        rescue ArgumentError
          invalid_values << "#{column}=#{value}"
        end
        break if invalid_values.size >= 10
      end

      add_check("#{check_prefix_for(path)}_numeric_coordinates", invalid_values.empty?, expected: [], actual: invalid_values)
    end

    def validate_csv_json_fields(path)
      invalid_values = []
      CSV.foreach(path, headers: true, encoding: 'UTF-8') do |row|
        json_columns(row.headers).each do |column|
          value = row[column]
          next if value.blank?

          JSON.parse(value)
        rescue JSON::ParserError
          invalid_values << "#{column}=#{value}"
        end
        break if invalid_values.size >= 10
      end

      add_check("#{check_prefix_for(path)}_json_fields", invalid_values.empty?, expected: [], actual: invalid_values)
    end

    def json_columns(headers)
      headers.select do |header|
        header.end_with?('_ids') ||
          header.end_with?('_keys') ||
          %w[business_categories license_categories location_uncertainty_reasons].include?(header)
      end
    end

    def validate_csv_no_local_absolute_paths(path)
      matches = []
      CSV.foreach(path, headers: true, encoding: 'UTF-8') do |row|
        row.each do |column, value|
          next if value.blank?
          next unless local_absolute_path?(value)

          matches << "#{column}=#{value}"
          break if matches.size >= 10
        end
        break if matches.size >= 10
      end

      add_check("#{check_prefix_for(path)}_no_local_absolute_paths", matches.empty?, expected: [], actual: matches)
    end


    def validate_csv_no_internal_columns(path)
      headers = CSV.open(path, 'r:UTF-8', &:readline)
      internal_columns = headers.select { |header| header.start_with?('internal_') }
      add_check("#{check_prefix_for(path)}_no_internal_columns", internal_columns.empty?, expected: [], actual: internal_columns)
    rescue CSV::MalformedCSVError, ArgumentError => error
      add_check("#{check_prefix_for(path)}_no_internal_columns", false, expected: 'parseable CSV headers', actual: error.message)
    end

    def local_absolute_path?(value)
      value.include?('/Users/') ||
        value.include?('/private/') ||
        value.include?('/var/folders/') ||
        value.match?(/[A-Za-z]:\\/)
    end

    def validate_reports_csv
      rows = CSV.read(paths.reports_csv, headers: true, encoding: 'UTF-8')
      add_check('reports_csv_headers', rows.headers == DatasetExport::Exporters::ReportsExporter::COLUMNS)
      add_check('reports_csv_has_rows', rows.size.positive?)

      database_reports = AlcoholLicense.where.not(reported_at: nil).distinct.count(:reported_at)
      expected_rows = rows.size == 1 ? 1 : database_reports
      add_check('reports_csv_row_count', rows.size == expected_rows, expected: expected_rows, actual: rows.size)

      exported_license_count = rows.sum { |row| row.fetch('license_count').to_i }
      database_license_count = if rows.size == 1
                                 AlcoholLicense.where(reported_at: Time.parse(rows.first.fetch('reported_at'))).count
                               else
                                 AlcoholLicense.count
                               end
      add_check('reports_csv_license_count_sum', exported_license_count == database_license_count, expected: database_license_count, actual: exported_license_count)

      validate_report_boundaries(rows)
      validate_known_report_values(rows)
    end

    def validate_report_boundaries(rows)
      database_first = AlcoholLicense.where.not(reported_at: nil).minimum(:reported_at)&.utc&.iso8601
      database_last = AlcoholLicense.where.not(reported_at: nil).maximum(:reported_at)&.utc&.iso8601

      if rows.size == 1
        actual = rows.first.fetch('reported_at')
        add_check('reports_csv_latest_only_report', actual == database_last, expected: database_last, actual: actual)
      else
        first_actual = rows.first.fetch('reported_at')
        last_actual = rows[-1].fetch('reported_at')
        add_check('reports_csv_first_report', first_actual == database_first, expected: database_first, actual: first_actual)
        add_check('reports_csv_last_report', last_actual == database_last, expected: database_last, actual: last_actual)
      end
    end

    def validate_known_report_values(rows)
      first_report = rows.find { |row| row.fetch('reported_at') == '2010-11-01T00:00:00Z' }
      latest_report = rows.find { |row| row.fetch('reported_at') == '2026-02-06T08:43:09Z' }

      if first_report
        add_check('reports_csv_first_report_license_count', first_report.fetch('license_count').to_i == 6706, expected: 6706, actual: first_report.fetch('license_count').to_i)
        add_check('reports_csv_first_report_point_count', first_report.fetch('point_count').to_i == 2606, expected: 2606, actual: first_report.fetch('point_count').to_i)
      end

      if latest_report
        add_check('reports_csv_latest_report_license_count', latest_report.fetch('license_count').to_i == 8142, expected: 8142, actual: latest_report.fetch('license_count').to_i)
        add_check('reports_csv_latest_report_geocoded_license_count', latest_report.fetch('geocoded_license_count').to_i == 8139, expected: 8139, actual: latest_report.fetch('geocoded_license_count').to_i)
        add_check('reports_csv_latest_report_point_count', latest_report.fetch('point_count').to_i == 3019, expected: 3019, actual: latest_report.fetch('point_count').to_i)
      end
    end

    def validate_alcohol_licenses_csv
      expected_headers = expected_alcohol_license_headers
      seen_ids = Set.new
      duplicate_ids = 0
      blank_ids = 0
      row_count = 0
      business_categories = Set.new
      license_categories = Set.new
      has_created_at = false
      has_updated_at = false

      CSV.foreach(paths.alcohol_licenses_csv, headers: true, encoding: 'UTF-8') do |row|
        if row_count.zero?
          headers = row.headers
          add_check('alcohol_licenses_csv_headers', headers == expected_headers, expected: expected_headers, actual: headers)
          has_created_at = headers.include?('created_at')
          has_updated_at = headers.include?('updated_at')
        end

        license_id = row.fetch('license_id')
        blank_ids += 1 if license_id.to_s.empty?
        duplicate_ids += 1 if license_id.present? && seen_ids.include?(license_id)
        seen_ids << license_id if license_id.present?
        business_categories << row.fetch('business_category')
        license_categories << row.fetch('license_category')
        row_count += 1
      end

      add_check('alcohol_licenses_csv_row_count', row_count == expected_alcohol_license_count, expected: expected_alcohol_license_count, actual: row_count)
      add_check('alcohol_licenses_csv_no_blank_license_id', blank_ids.zero?, expected: 0, actual: blank_ids)
      add_check('alcohol_licenses_csv_no_duplicate_license_id', duplicate_ids.zero?, expected: 0, actual: duplicate_ids)
      add_check('alcohol_licenses_csv_business_categories', business_categories.subset?(Set.new(%w[detal gastronomia])), expected: %w[detal gastronomia], actual: business_categories.to_a.sort)
      add_check('alcohol_licenses_csv_license_categories', license_categories.subset?(Set.new(%w[A B C])), expected: %w[A B C], actual: license_categories.to_a.sort)
      add_check('alcohol_licenses_csv_no_created_at', !has_created_at, expected: false, actual: has_created_at)
      add_check('alcohol_licenses_csv_no_updated_at', !has_updated_at, expected: false, actual: has_updated_at)
    end

    def expected_alcohol_license_headers
      headers = DatasetExport::LicenseRows::BASE_COLUMNS
      return headers unless alcohol_licenses_csv_has_business_name?

      index = headers.index('business_key')
      headers.dup.insert(index + 1, DatasetExport::LicenseRows::BUSINESS_NAME_COLUMN)
    end

    def alcohol_licenses_csv_has_business_name?
      CSV.open(paths.alcohol_licenses_csv, 'r:UTF-8', &:first).include?(DatasetExport::LicenseRows::BUSINESS_NAME_COLUMN)
    end

    def expected_alcohol_license_count
      if paths.reports_csv.exist?
        CSV.read(paths.reports_csv, headers: true, encoding: 'UTF-8').sum { |row| row.fetch('license_count').to_i }
      else
        AlcoholLicense.count
      end
    end

    def validate_license_points_csv
      expected_headers = expected_license_point_headers
      row_count = 0
      blank_coordinates = 0
      outside_bbox = 0
      counts_by_reported_at = Hash.new(0)

      CSV.foreach(paths.license_points_csv, headers: true, encoding: 'UTF-8') do |row|
        if row_count.zero?
          headers = row.headers
          add_check('license_points_csv_headers', headers == expected_headers, expected: expected_headers, actual: headers)
        end

        latitude = row.fetch('latitude')
        longitude = row.fetch('longitude')
        blank_coordinates += 1 if latitude.to_s.empty? || longitude.to_s.empty?
        outside_bbox += 1 unless in_krakow_bbox?(latitude, longitude)
        counts_by_reported_at[row.fetch('reported_at')] += 1
        row_count += 1
      end

      add_check('license_points_csv_row_count', row_count == expected_license_point_count, expected: expected_license_point_count, actual: row_count)
      add_check('license_points_csv_no_blank_coordinates', blank_coordinates.zero?, expected: 0, actual: blank_coordinates)
      add_check('license_points_csv_coordinates_in_bbox', outside_bbox.zero?, expected: 0, actual: outside_bbox)
      validate_license_point_report_counts(counts_by_reported_at)
    end

    def expected_license_point_headers
      headers = DatasetExport::PointRows::COLUMNS
      return headers unless license_points_csv_has_business_names?

      with_display = insert_after(headers, 'business_key', DatasetExport::PointRows::DISPLAY_BUSINESS_NAME_COLUMN)
      insert_after(with_display, 'business_keys', DatasetExport::PointRows::BUSINESS_NAMES_COLUMN)
    end

    def license_points_csv_has_business_names?
      CSV.open(paths.license_points_csv, 'r:UTF-8', &:first).include?(DatasetExport::PointRows::DISPLAY_BUSINESS_NAME_COLUMN)
    end

    def expected_license_point_count
      if paths.reports_csv.exist?
        CSV.read(paths.reports_csv, headers: true, encoding: 'UTF-8').sum { |row| row.fetch('point_count').to_i }
      else
        LicensePointGroup.count
      end
    end

    def expected_raw_location_count
      relation = Location.joins(:alcohol_licenses).select('locations.address_1', 'locations.address_2')

      if paths.reports_csv.exist?
        reports = CSV.read(paths.reports_csv, headers: true, encoding: 'UTF-8')
        relation = relation.where(alcohol_licenses: { reported_at: Time.parse(reports.first.fetch('reported_at')) }) if reports.size == 1
      end

      relation.map do |location|
        DatasetExport::StableId.raw_location_id(
          source_address_1: location.address_1,
          source_address_2: location.address_2
        )
      end.uniq.size
    end

    def expected_normalized_location_count
      relation = TransformedLocation.all

      if paths.reports_csv.exist?
        reports = CSV.read(paths.reports_csv, headers: true, encoding: 'UTF-8')
        if reports.size == 1
          relation = relation
            .joins(locations: :alcohol_licenses)
            .where(alcohol_licenses: { reported_at: Time.parse(reports.first.fetch('reported_at')) })
            .distinct
        end
      end

      relation.count
    end

    def expected_address_correction_count
      expected_address_correction_scope.count
    end

    def expected_selected_address_correction_count
      expected_address_correction_scope.selected.count
    end

    def expected_address_correction_scope
      relation = AddressCorrection.all
      return relation unless paths.reports_csv.exist?

      reports = CSV.read(paths.reports_csv, headers: true, encoding: 'UTF-8')
      return relation unless reports.size == 1

      latest_location_ids = AlcoholLicense
        .where(reported_at: Time.parse(reports.first.fetch('reported_at')))
        .distinct
        .pluck(:location_id)

      relation.where(location_id: latest_location_ids).where(source_location_id: [nil, *latest_location_ids])
    end

    def expected_geocoding_result_count
      relation = GeocodingResult.where.not(source: DatasetExport::GeocodingResultRows::EXCLUDED_SOURCES)
      return relation.count unless paths.reports_csv.exist?

      reports = CSV.read(paths.reports_csv, headers: true, encoding: 'UTF-8')
      return relation.count unless reports.size == 1

      relation
        .joins(transformed_location: { locations: :alcohol_licenses })
        .where(alcohol_licenses: { reported_at: Time.parse(reports.first.fetch('reported_at')) })
        .distinct
        .count
    end

    def expected_geocoding_review_count
      relation = GeocodingReview.all
      return relation.count unless paths.reports_csv.exist?

      reports = CSV.read(paths.reports_csv, headers: true, encoding: 'UTF-8')
      return relation.count unless reports.size == 1

      relation
        .joins(transformed_location: { locations: :alcohol_licenses })
        .where(alcohol_licenses: { reported_at: Time.parse(reports.first.fetch('reported_at')) })
        .distinct
        .count
    end

    def validate_license_point_report_counts(counts_by_reported_at)
      return if counts_by_reported_at.empty?

      database_first = AlcoholLicense.where.not(reported_at: nil).minimum(:reported_at)
      database_last = AlcoholLicense.where.not(reported_at: nil).maximum(:reported_at)
      return unless database_first && database_last

      if counts_by_reported_at.size == 1
        actual = counts_by_reported_at[database_last.utc.iso8601]
        expected = license_point_count_for_report(database_last)
        add_check('license_points_csv_latest_report_count', actual == expected, expected: expected, actual: actual)
      else
        first_actual = counts_by_reported_at[database_first.utc.iso8601]
        first_expected = license_point_count_for_report(database_first)
        last_actual = counts_by_reported_at[database_last.utc.iso8601]
        last_expected = license_point_count_for_report(database_last)
        add_check('license_points_csv_first_report_count', first_actual == first_expected, expected: first_expected, actual: first_actual)
        add_check('license_points_csv_last_report_count', last_actual == last_expected, expected: last_expected, actual: last_actual)
      end
    end

    def validate_license_point_relations
      point_counts = {}
      CSV.foreach(paths.license_points_csv, headers: true, encoding: 'UTF-8') do |row|
        point_counts[row.fetch('point_id')] = row.fetch('license_count').to_i
      end

      missing_point_ids = 0
      license_counts = Hash.new(0)
      CSV.foreach(paths.alcohol_licenses_csv, headers: true, encoding: 'UTF-8') do |row|
        next unless row.fetch('geocoded') == 'true'

        point_id = row.fetch('point_id')
        missing_point_ids += 1 if point_id.to_s.empty? || !point_counts.key?(point_id)
        license_counts[point_id] += 1 if point_counts.key?(point_id)
      end

      mismatched_counts = point_counts.count { |point_id, expected| license_counts.fetch(point_id, 0) != expected }
      add_check('alcohol_licenses_csv_point_ids_exist', missing_point_ids.zero?, expected: 0, actual: missing_point_ids)
      add_check('license_points_csv_license_count_matches_alcohol_licenses', mismatched_counts.zero?, expected: 0, actual: mismatched_counts)
    end

    def validate_point_memberships_csv
      row_count = 0
      invalid_methods = Set.new
      duplicate_license_ids = 0
      seen_license_ids = Set.new
      allowed_methods = Set.new(%w[license_point_group fallback_business_location not_geocoded])

      CSV.foreach(paths.point_memberships_csv, headers: true, encoding: 'UTF-8') do |row|
        if row_count.zero?
          headers = row.headers
          add_check('point_memberships_csv_headers', headers == DatasetExport::MembershipRows::COLUMNS, expected: DatasetExport::MembershipRows::COLUMNS, actual: headers)
        end

        license_id = row.fetch('license_id')
        duplicate_license_ids += 1 if license_id.present? && seen_license_ids.include?(license_id)
        seen_license_ids << license_id if license_id.present?
        invalid_methods << row.fetch('membership_method') unless allowed_methods.include?(row.fetch('membership_method'))
        row_count += 1
      end

      add_check('point_memberships_csv_row_count', row_count == expected_alcohol_license_count, expected: expected_alcohol_license_count, actual: row_count)
      add_check('point_memberships_csv_no_duplicate_license_id', duplicate_license_ids.zero?, expected: 0, actual: duplicate_license_ids)
      add_check('point_memberships_csv_membership_methods', invalid_methods.empty?, expected: allowed_methods.to_a.sort, actual: invalid_methods.to_a.sort)
    end

    def validate_point_membership_relations
      point_counts = {}
      CSV.foreach(paths.license_points_csv, headers: true, encoding: 'UTF-8') do |row|
        point_counts[row.fetch('point_id')] = row.fetch('license_count').to_i
      end

      licenses = {}
      geocoded_license_count = 0
      CSV.foreach(paths.alcohol_licenses_csv, headers: true, encoding: 'UTF-8') do |row|
        geocoded = row.fetch('geocoded') == 'true'
        geocoded_license_count += 1 if geocoded
        licenses[row.fetch('license_id')] = {
          geocoded: geocoded,
          point_id: row.fetch('point_id')
        }
      end

      assigned_count = 0
      missing_point_ids = 0
      alcohol_license_mismatches = 0
      not_geocoded_mismatches = 0
      unknown_license_ids = 0
      memberships_by_point_id = Hash.new(0)

      CSV.foreach(paths.point_memberships_csv, headers: true, encoding: 'UTF-8') do |row|
        license = licenses[row.fetch('license_id')]
        if license.nil?
          unknown_license_ids += 1
          next
        end

        point_id = row.fetch('point_id')
        method = row.fetch('membership_method')

        if license.fetch(:geocoded)
          assigned_count += 1 if point_id.present?
          missing_point_ids += 1 if point_id.blank? || !point_counts.key?(point_id)
          alcohol_license_mismatches += 1 if point_id != license.fetch(:point_id)
          memberships_by_point_id[point_id] += 1 if point_id.present?
        elsif point_id.present? || method != 'not_geocoded'
          not_geocoded_mismatches += 1
        end
      end

      mismatched_counts = point_counts.count { |point_id, expected| memberships_by_point_id.fetch(point_id, 0) != expected }

      add_check('point_memberships_csv_no_unknown_license_ids', unknown_license_ids.zero?, expected: 0, actual: unknown_license_ids)
      add_check('point_memberships_csv_geocoded_license_count', assigned_count == geocoded_license_count, expected: geocoded_license_count, actual: assigned_count)
      add_check('point_memberships_csv_point_ids_exist', missing_point_ids.zero?, expected: 0, actual: missing_point_ids)
      add_check('point_memberships_csv_matches_alcohol_licenses', alcohol_license_mismatches.zero?, expected: 0, actual: alcohol_license_mismatches)
      add_check('point_memberships_csv_not_geocoded_shape', not_geocoded_mismatches.zero?, expected: 0, actual: not_geocoded_mismatches)
      add_check('license_points_csv_license_count_matches_point_memberships', mismatched_counts.zero?, expected: 0, actual: mismatched_counts)
    end

    def validate_locations_raw_csv
      seen_ids = Set.new
      duplicate_ids = 0
      blank_ids = 0
      row_count = 0

      CSV.foreach(paths.locations_raw_csv, headers: true, encoding: 'UTF-8') do |row|
        if row_count.zero?
          headers = row.headers
          add_check('locations_raw_csv_headers', headers == DatasetExport::LocationRows::COLUMNS, expected: DatasetExport::LocationRows::COLUMNS, actual: headers)
        end

        raw_location_id = row.fetch('raw_location_id')
        blank_ids += 1 if raw_location_id.to_s.empty?
        duplicate_ids += 1 if raw_location_id.present? && seen_ids.include?(raw_location_id)
        seen_ids << raw_location_id if raw_location_id.present?
        row_count += 1
      end

      add_check('locations_raw_csv_row_count', row_count == expected_raw_location_count, expected: expected_raw_location_count, actual: row_count)
      add_check('locations_raw_csv_no_blank_raw_location_id', blank_ids.zero?, expected: 0, actual: blank_ids)
      add_check('locations_raw_csv_no_duplicate_raw_location_id', duplicate_ids.zero?, expected: 0, actual: duplicate_ids)
    end

    def validate_locations_normalized_csv
      seen_ids = Set.new
      duplicate_ids = 0
      blank_ids = 0
      row_count = 0
      outside_bbox = 0
      address_kinds = Set.new
      google_columns = []
      allowed_address_kinds = Set.new(%w[compound_address landmark near_building parcel pavilion street_address])

      CSV.foreach(paths.locations_normalized_csv, headers: true, encoding: 'UTF-8') do |row|
        if row_count.zero?
          headers = row.headers
          google_columns = headers.grep(/google/i)
          add_check('locations_normalized_csv_headers', headers == DatasetExport::NormalizedLocationRows::COLUMNS, expected: DatasetExport::NormalizedLocationRows::COLUMNS, actual: headers)
        end

        normalized_location_id = row.fetch('normalized_location_id')
        blank_ids += 1 if normalized_location_id.to_s.empty?
        duplicate_ids += 1 if normalized_location_id.present? && seen_ids.include?(normalized_location_id)
        seen_ids << normalized_location_id if normalized_location_id.present?
        address_kinds << row.fetch('address_kind')

        latitude = row.fetch('latitude')
        longitude = row.fetch('longitude')
        outside_bbox += 1 if latitude.present? && longitude.present? && !in_krakow_bbox?(latitude, longitude)

        row_count += 1
      end

      add_check('locations_normalized_csv_row_count', row_count == expected_normalized_location_count, expected: expected_normalized_location_count, actual: row_count)
      add_check('locations_normalized_csv_no_blank_normalized_location_id', blank_ids.zero?, expected: 0, actual: blank_ids)
      add_check('locations_normalized_csv_no_duplicate_normalized_location_id', duplicate_ids.zero?, expected: 0, actual: duplicate_ids)
      add_check('locations_normalized_csv_address_kinds', address_kinds.subset?(allowed_address_kinds), expected: allowed_address_kinds.to_a.sort, actual: address_kinds.to_a.sort)
      add_check('locations_normalized_csv_coordinates_in_bbox', outside_bbox.zero?, expected: 0, actual: outside_bbox)
      add_check('locations_normalized_csv_no_google_columns', google_columns.empty?, expected: [], actual: google_columns)
    end

    def validate_address_corrections_csv
      seen_ids = Set.new
      duplicate_ids = 0
      blank_ids = 0
      row_count = 0
      selected_count = 0

      CSV.foreach(paths.address_corrections_csv, headers: true, encoding: 'UTF-8') do |row|
        if row_count.zero?
          headers = row.headers
          add_check('address_corrections_csv_headers', headers == DatasetExport::AddressCorrectionRows::COLUMNS, expected: DatasetExport::AddressCorrectionRows::COLUMNS, actual: headers)
        end

        correction_id = row.fetch('correction_id')
        blank_ids += 1 if correction_id.to_s.empty?
        duplicate_ids += 1 if correction_id.present? && seen_ids.include?(correction_id)
        seen_ids << correction_id if correction_id.present?
        selected_count += 1 if row.fetch('selected') == 'true'
        row_count += 1
      end

      add_check('address_corrections_csv_row_count', row_count == expected_address_correction_count, expected: expected_address_correction_count, actual: row_count)
      add_check('address_corrections_csv_selected_count', selected_count == expected_selected_address_correction_count, expected: expected_selected_address_correction_count, actual: selected_count)
      add_check('address_corrections_csv_no_blank_correction_id', blank_ids.zero?, expected: 0, actual: blank_ids)
      add_check('address_corrections_csv_no_duplicate_correction_id', duplicate_ids.zero?, expected: 0, actual: duplicate_ids)
    end

    def validate_geocoding_results_csv
      seen_ids = Set.new
      duplicate_ids = 0
      blank_ids = 0
      row_count = 0
      google_rows = 0
      selected_without_coordinates = 0
      raw_response_column = false

      CSV.foreach(paths.geocoding_results_csv, headers: true, encoding: 'UTF-8') do |row|
        if row_count.zero?
          headers = row.headers
          raw_response_column = headers.include?('raw_response')
          add_check('geocoding_results_csv_headers', headers == DatasetExport::GeocodingResultRows::COLUMNS, expected: DatasetExport::GeocodingResultRows::COLUMNS, actual: headers)
        end

        geocoding_result_id = row.fetch('geocoding_result_id')
        blank_ids += 1 if geocoding_result_id.to_s.empty?
        duplicate_ids += 1 if geocoding_result_id.present? && seen_ids.include?(geocoding_result_id)
        seen_ids << geocoding_result_id if geocoding_result_id.present?
        google_rows += 1 if DatasetExport::GeocodingResultRows::EXCLUDED_SOURCES.include?(row.fetch('source'))
        selected_without_coordinates += 1 if row.fetch('selected') == 'true' && (row.fetch('latitude').blank? || row.fetch('longitude').blank?)
        row_count += 1
      end

      add_check('geocoding_results_csv_row_count', row_count == expected_geocoding_result_count, expected: expected_geocoding_result_count, actual: row_count)
      add_check('geocoding_results_csv_no_blank_geocoding_result_id', blank_ids.zero?, expected: 0, actual: blank_ids)
      add_check('geocoding_results_csv_no_duplicate_geocoding_result_id', duplicate_ids.zero?, expected: 0, actual: duplicate_ids)
      add_check('geocoding_results_csv_no_google_rows', google_rows.zero?, expected: 0, actual: google_rows)
      add_check('geocoding_results_csv_selected_have_coordinates', selected_without_coordinates.zero?, expected: 0, actual: selected_without_coordinates)
      add_check('geocoding_results_csv_no_raw_response', !raw_response_column, expected: false, actual: raw_response_column)
    end

    def validate_geocoding_reviews_csv
      seen_ids = Set.new
      duplicate_ids = 0
      blank_ids = 0
      row_count = 0
      invalid_statuses = Set.new

      CSV.foreach(paths.geocoding_reviews_csv, headers: true, encoding: 'UTF-8') do |row|
        if row_count.zero?
          headers = row.headers
          add_check('geocoding_reviews_csv_headers', headers == DatasetExport::GeocodingReviewRows::COLUMNS, expected: DatasetExport::GeocodingReviewRows::COLUMNS, actual: headers)
        end

        review_id = row.fetch('review_id')
        blank_ids += 1 if review_id.to_s.empty?
        duplicate_ids += 1 if review_id.present? && seen_ids.include?(review_id)
        seen_ids << review_id if review_id.present?
        invalid_statuses << row.fetch('review_status') unless GeocodingReview::STATUSES.include?(row.fetch('review_status'))
        row_count += 1
      end

      add_check('geocoding_reviews_csv_row_count', row_count == expected_geocoding_review_count, expected: expected_geocoding_review_count, actual: row_count)
      add_check('geocoding_reviews_csv_no_blank_review_id', blank_ids.zero?, expected: 0, actual: blank_ids)
      add_check('geocoding_reviews_csv_no_duplicate_review_id', duplicate_ids.zero?, expected: 0, actual: duplicate_ids)
      add_check('geocoding_reviews_csv_review_statuses', invalid_statuses.empty?, expected: GeocodingReview::STATUSES.sort, actual: invalid_statuses.to_a.sort)
    end

    def validate_sim_populations_csv
      row_count = 0
      counts_by_observed_on = Hash.new(0)
      latest_snapshot_for_last_report = nil

      CSV.foreach(paths.sim_populations_csv, headers: true, encoding: 'UTF-8') do |row|
        if row_count.zero?
          headers = row.headers
          add_check('sim_populations_csv_headers', headers == DatasetExport::SimPopulationRows::COLUMNS, expected: DatasetExport::SimPopulationRows::COLUMNS, actual: headers)
        end

        counts_by_observed_on[row.fetch('observed_on')] += 1
        row_count += 1
      end

      last_reported_at = AlcoholLicense.maximum(:reported_at)
      if last_reported_at
        latest_snapshot_for_last_report = SimPopulation
          .where('observed_on <= ?', last_reported_at.to_date)
          .maximum(:observed_on)
          &.iso8601
      end

      invalid_snapshot_sizes = counts_by_observed_on.reject { |_observed_on, count| count == Sim::Units.all.size }

      add_check('sim_populations_csv_row_count', row_count == SimPopulation.count, expected: SimPopulation.count, actual: row_count)
      return unless SimPopulation.exists?

      add_check('sim_populations_csv_each_snapshot_has_all_units', invalid_snapshot_sizes.empty?, expected: Sim::Units.all.size, actual: invalid_snapshot_sizes)
      add_check('sim_populations_csv_latest_snapshot_for_last_report', latest_snapshot_for_last_report == '2025-12-31', expected: '2025-12-31', actual: latest_snapshot_for_last_report)
    end

    def validate_sim_units_geojson
      payload = JSON.parse(paths.sim_units_geojson.read)
      features = payload.fetch('features', [])
      invalid_geometries = features.count { |feature| !valid_sim_geometry?(feature.fetch('geometry', {})) }
      property_keys = features.first&.fetch('properties', {})&.keys || []
      expected_keys = %w[sim_unit_code sim_unit_name district_code district_name area_km2]
      area_sum = features.sum { |feature| feature.fetch('properties').fetch('area_km2').to_f }.round(3)
      expected_area_sum = Sim::Units.all.sum { |unit| unit.fetch(:area_km2) }.round(3)

      add_check('sim_units_geojson_feature_collection', payload.fetch('type', nil) == 'FeatureCollection', expected: 'FeatureCollection', actual: payload.fetch('type', nil))
      add_check('sim_units_geojson_feature_count', features.size == Sim::Units.all.size, expected: Sim::Units.all.size, actual: features.size)
      add_check('sim_units_geojson_property_keys', property_keys == expected_keys, expected: expected_keys, actual: property_keys)
      add_check('sim_units_geojson_valid_geometries', invalid_geometries.zero?, expected: 0, actual: invalid_geometries)
      add_check('sim_units_geojson_area_sum_matches_source', (area_sum - expected_area_sum).abs <= 0.001, expected: expected_area_sum, actual: area_sum)
    end

    def validate_aggregates_csv
      validate_aggregate_file(paths.city_summary_by_report_csv, 'city_summary_by_report_csv', expected_report_count)
      validate_aggregate_file(paths.district_summary_by_report_csv, 'district_summary_by_report_csv', expected_report_count * district_count)
      validate_aggregate_file(paths.sim_summary_by_report_csv, 'sim_summary_by_report_csv', expected_report_count * Sim::Units.all.size)
      validate_latest_aggregate_values
    end

    def validate_license_points_latest_geojson
      payload = JSON.parse(paths.license_points_latest_geojson.read)
      features = payload.fetch('features', [])
      invalid_geometry_types = 0
      blank_geometries = 0
      invalid_coordinate_order = 0

      features.each do |feature|
        geometry = feature.fetch('geometry', nil)
        if geometry.blank?
          blank_geometries += 1
          next
        end

        invalid_geometry_types += 1 unless geometry.fetch('type', nil) == 'Point'
        coordinates = geometry.fetch('coordinates', [])
        if coordinates.size < 2 || !in_krakow_bbox?(coordinates[1], coordinates[0])
          invalid_coordinate_order += 1
        end
      end

      add_check('license_points_latest_geojson_feature_collection', payload.fetch('type', nil) == 'FeatureCollection', expected: 'FeatureCollection', actual: payload.fetch('type', nil))
      add_check('license_points_latest_geojson_feature_count', features.size == expected_latest_license_point_count, expected: expected_latest_license_point_count, actual: features.size)
      add_check('license_points_latest_geojson_point_geometries', invalid_geometry_types.zero?, expected: 0, actual: invalid_geometry_types)
      add_check('license_points_latest_geojson_no_blank_geometries', blank_geometries.zero?, expected: 0, actual: blank_geometries)
      add_check('license_points_latest_geojson_coordinate_order_lon_lat', invalid_coordinate_order.zero?, expected: 0, actual: invalid_coordinate_order)
    end

    def validate_aggregate_file(path, check_prefix, expected_rows)
      row_count = 0
      CSV.foreach(path, headers: true, encoding: 'UTF-8') do |row|
        if row_count.zero?
          headers = row.headers
          add_check("#{check_prefix}_headers", headers == DatasetExport::AggregateRows::COLUMNS, expected: DatasetExport::AggregateRows::COLUMNS, actual: headers)
        end
        row_count += 1
      end

      add_check("#{check_prefix}_row_count", row_count == expected_rows, expected: expected_rows, actual: row_count)
    end

    def validate_latest_aggregate_values
      latest_reported_at = AlcoholLicense.maximum(:reported_at)&.utc&.iso8601
      return unless latest_reported_at
      return unless AlcoholLicense.where(reported_at: Time.parse(latest_reported_at)).count == 8142

      city = aggregate_row(paths.city_summary_by_report_csv, reported_at: latest_reported_at, area_code: 'Krakow')
      district_i = aggregate_row(paths.district_summary_by_report_csv, reported_at: latest_reported_at, area_code: 'I')
      kazimierz = aggregate_row(paths.sim_summary_by_report_csv, reported_at: latest_reported_at, area_code: 'I.8')

      add_check('aggregates_latest_city_point_count', city&.fetch('point_count').to_i == 3019, expected: 3019, actual: city&.fetch('point_count')&.to_i)
      add_check('aggregates_latest_city_license_count', city&.fetch('license_count').to_i == 8142, expected: 8142, actual: city&.fetch('license_count')&.to_i)
      add_check('aggregates_latest_city_population_total', city&.fetch('population_total').to_i == 703707, expected: 703707, actual: city&.fetch('population_total')&.to_i)
      add_check('aggregates_latest_district_i_point_count', district_i&.fetch('point_count').to_i == 1068, expected: 1068, actual: district_i&.fetch('point_count')&.to_i)
      add_check('aggregates_latest_district_i_license_count', district_i&.fetch('license_count').to_i == 2969, expected: 2969, actual: district_i&.fetch('license_count')&.to_i)
      add_check('aggregates_latest_kazimierz_point_count', kazimierz&.fetch('point_count').to_i == 302, expected: 302, actual: kazimierz&.fetch('point_count')&.to_i)
    end

    def aggregate_row(path, reported_at:, area_code:)
      CSV.foreach(path, headers: true, encoding: 'UTF-8') do |row|
        return row if row.fetch('reported_at') == reported_at && row.fetch('area_code') == area_code
      end

      nil
    end

    def aggregate_paths_exist?
      paths.city_summary_by_report_csv.exist? &&
        paths.district_summary_by_report_csv.exist? &&
        paths.sim_summary_by_report_csv.exist?
    end

    def expected_report_count
      CSV.read(paths.reports_csv, headers: true, encoding: 'UTF-8').size
    end

    def expected_latest_license_point_count
      CSV.read(paths.reports_csv, headers: true, encoding: 'UTF-8')[-1].fetch('point_count').to_i
    end

    def district_count
      Sim::Units.all.map { |unit| unit.fetch(:district) }.uniq.size
    end

    def validate_raw_location_relations
      location_counts = {}
      CSV.foreach(paths.locations_raw_csv, headers: true, encoding: 'UTF-8') do |row|
        location_counts[row.fetch('raw_location_id')] = row.fetch('license_count').to_i
      end

      license_counts = Hash.new(0)
      missing_raw_location_ids = 0
      CSV.foreach(paths.alcohol_licenses_csv, headers: true, encoding: 'UTF-8') do |row|
        raw_location_id = row.fetch('raw_location_id')
        missing_raw_location_ids += 1 if raw_location_id.blank? || !location_counts.key?(raw_location_id)
        license_counts[raw_location_id] += 1 if raw_location_id.present?
      end

      mismatched_counts = location_counts.count { |raw_location_id, expected| license_counts.fetch(raw_location_id, 0) != expected }

      add_check('alcohol_licenses_csv_raw_location_ids_exist', missing_raw_location_ids.zero?, expected: 0, actual: missing_raw_location_ids)
      add_check('locations_raw_csv_license_count_matches_alcohol_licenses', mismatched_counts.zero?, expected: 0, actual: mismatched_counts)
    end

    def validate_address_correction_relations
      raw_location_ids = Set.new
      CSV.foreach(paths.locations_raw_csv, headers: true, encoding: 'UTF-8') do |row|
        raw_location_ids << row.fetch('raw_location_id')
      end

      missing_raw_location_ids = 0
      missing_source_raw_location_ids = 0
      CSV.foreach(paths.address_corrections_csv, headers: true, encoding: 'UTF-8') do |row|
        raw_location_id = row.fetch('raw_location_id')
        source_raw_location_id = row.fetch('source_raw_location_id')

        missing_raw_location_ids += 1 if raw_location_id.blank? || !raw_location_ids.include?(raw_location_id)
        missing_source_raw_location_ids += 1 if source_raw_location_id.present? && !raw_location_ids.include?(source_raw_location_id)
      end

      add_check('address_corrections_csv_raw_location_ids_exist', missing_raw_location_ids.zero?, expected: 0, actual: missing_raw_location_ids)
      add_check('address_corrections_csv_source_raw_location_ids_exist', missing_source_raw_location_ids.zero?, expected: 0, actual: missing_source_raw_location_ids)
    end

    def validate_geocoding_result_relations
      normalized_location_ids = Set.new
      CSV.foreach(paths.locations_normalized_csv, headers: true, encoding: 'UTF-8') do |row|
        normalized_location_ids << row.fetch('normalized_location_id')
      end

      missing_normalized_location_ids = 0
      CSV.foreach(paths.geocoding_results_csv, headers: true, encoding: 'UTF-8') do |row|
        normalized_location_id = row.fetch('normalized_location_id')
        missing_normalized_location_ids += 1 if normalized_location_id.blank? || !normalized_location_ids.include?(normalized_location_id)
      end

      add_check('geocoding_results_csv_normalized_location_ids_exist', missing_normalized_location_ids.zero?, expected: 0, actual: missing_normalized_location_ids)
    end

    def validate_geocoding_review_relations
      normalized_location_ids = Set.new
      CSV.foreach(paths.locations_normalized_csv, headers: true, encoding: 'UTF-8') do |row|
        normalized_location_ids << row.fetch('normalized_location_id')
      end

      geocoding_result_ids = Set.new
      if paths.geocoding_results_csv.exist?
        CSV.foreach(paths.geocoding_results_csv, headers: true, encoding: 'UTF-8') do |row|
          geocoding_result_ids << row.fetch('geocoding_result_id')
        end
      end

      missing_normalized_location_ids = 0
      missing_selected_geocoding_result_ids = 0
      missing_manual_geocoding_result_ids = 0
      CSV.foreach(paths.geocoding_reviews_csv, headers: true, encoding: 'UTF-8') do |row|
        normalized_location_id = row.fetch('normalized_location_id')
        selected_geocoding_result_id = row.fetch('selected_geocoding_result_id')
        manual_geocoding_result_id = row.fetch('manual_geocoding_result_id')

        missing_normalized_location_ids += 1 if normalized_location_id.blank? || !normalized_location_ids.include?(normalized_location_id)
        missing_selected_geocoding_result_ids += 1 if selected_geocoding_result_id.present? && !geocoding_result_ids.include?(selected_geocoding_result_id)
        missing_manual_geocoding_result_ids += 1 if manual_geocoding_result_id.present? && !geocoding_result_ids.include?(manual_geocoding_result_id)
      end

      add_check('geocoding_reviews_csv_normalized_location_ids_exist', missing_normalized_location_ids.zero?, expected: 0, actual: missing_normalized_location_ids)
      add_check('geocoding_reviews_csv_selected_geocoding_result_ids_exist', missing_selected_geocoding_result_ids.zero?, expected: 0, actual: missing_selected_geocoding_result_ids)
      add_check('geocoding_reviews_csv_manual_geocoding_result_ids_exist', missing_manual_geocoding_result_ids.zero?, expected: 0, actual: missing_manual_geocoding_result_ids)
    end

    def license_point_count_for_report(reported_at)
      LicensePointGroup.where(reported_at: reported_at).count + fallback_point_count_for_report(reported_at)
    end

    def fallback_point_count_for_report(reported_at)
      AlcoholLicense
        .joins(:business, location: :transformed_location)
        .where(reported_at: reported_at, license_point_group_id: nil)
        .where.not(transformed_locations: { latitude: nil, longtitude: nil })
        .group(
          'alcohol_licenses.reported_at',
          'businesses.name',
          'transformed_locations.address_1',
          'transformed_locations.building_number',
          'transformed_locations.address_kind',
          'transformed_locations.address_relation',
          'transformed_locations.unit_number',
          'transformed_locations.parcel_number',
          'transformed_locations.parcel_region',
          'transformed_locations.parcel_cadastral_unit',
          'transformed_locations.latitude',
          'transformed_locations.longtitude'
        )
        .count
        .size
    end

    def in_krakow_bbox?(latitude, longitude)
      lat = latitude.to_f
      lng = longitude.to_f
      lat.between?(49.9, 50.2) && lng.between?(19.7, 20.3)
    end

    def valid_sim_geometry?(geometry)
      case geometry.fetch('type', nil)
      when 'Polygon'
        valid_polygon_coordinates?(geometry.fetch('coordinates', []))
      when 'MultiPolygon'
        geometry.fetch('coordinates', []).any? && geometry.fetch('coordinates').all? { |polygon| valid_polygon_coordinates?(polygon) }
      else
        false
      end
    end

    def valid_polygon_coordinates?(rings)
      rings.any? && rings.all? do |ring|
        ring.size >= 4 &&
          ring.first == ring.last &&
          ring.all? { |coordinate| coordinate.is_a?(Array) && coordinate.size >= 2 }
      end
    end

    def insert_after(columns, after, new_column)
      index = columns.index(after)
      columns.dup.insert(index + 1, new_column)
    end

    def add_check(name, passed, expected: nil, actual: nil)
      checks << {
        name: name,
        passed: passed,
        expected: expected,
        actual: actual
      }
      errors << name unless passed
    end

    def write_report
      report = {
        generated_at: Time.now.utc.iso8601,
        status: errors.empty? ? 'passed' : 'failed',
        passed: errors.empty?,
        summary: {
          total_checks: checks.size,
          passed_checks: checks.count { |check| check.fetch(:passed) },
          failed_checks: checks.count { |check| !check.fetch(:passed) }
        },
        errors: errors,
        checks: checks
      }
      DatasetExport::JsonWriter.write(paths.validation_report_json, report)
      write_markdown_report(report)
    end

    def write_markdown_report(report)
      failed = report.fetch(:checks).reject { |check| check.fetch(:passed) }
      lines = [
        '# Validation Report',
        '',
        "- Generated at: `#{report.fetch(:generated_at)}`",
        "- Passed: #{report.fetch(:passed)}",
        "- Checks: #{report.fetch(:checks).size}",
        "- Failed checks: #{failed.size}",
        ''
      ]

      if failed.empty?
        lines << 'All validation checks passed.'
      else
        lines << '## Failed Checks'
        lines << ''
        failed.each do |check|
          lines << "- `#{check.fetch(:name)}` expected `#{check.fetch(:expected).inspect}`, actual `#{check.fetch(:actual).inspect}`"
        end
      end

      FileUtils.mkdir_p(File.dirname(paths.validation_report_md))
      File.write(paths.validation_report_md, "#{lines.join("\n")}\n", encoding: 'UTF-8')
    end
  end
end
