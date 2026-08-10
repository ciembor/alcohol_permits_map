require 'json'

require 'dataset_export/stable_id'
require 'geocoding/location_uncertainty'
require 'sim/locator'

module DatasetExport
  class PointRows
    COLUMNS = %w[
      point_id
      internal_license_point_group_id
      report_id
      reported_at
      report_date
      latitude
      longitude
      crs
      normalized_location_id
      raw_location_ids
      display_address
      address_1
      building_number
      unit_number
      address_kind
      address_relation
      parcel_number
      parcel_region
      parcel_cadastral_unit
      business_key
      business_keys
      business_count
      business_id_count
      license_count
      license_categories
      license_count_a
      license_count_b
      license_count_c
      business_categories
      retail_license_count
      gastronomy_license_count
      retail_flag
      gastronomy_flag
      mixed_flag
      similarity_floor
      geocoding_source
      geocoding_strategy
      geocoding_precision
      geocoding_query
      location_uncertain
      location_uncertainty_reasons
      latest_review_status
      sim_unit_code
      sim_unit_name
      district_code
      district_name
      expires_at_max
    ].freeze

    DISPLAY_BUSINESS_NAME_COLUMN = 'display_business_name'.freeze
    BUSINESS_NAMES_COLUMN = 'business_names'.freeze

    def initialize(include_business_names: false, latest_only: false, sim_locator: Sim::Locator.new)
      @include_business_names = include_business_names
      @latest_only = latest_only
      @sim_locator = sim_locator
      @latest_review_status_by_location_id = build_latest_review_status_by_location_id
    end

    def columns
      return COLUMNS unless include_business_names

      with_display = insert_after(COLUMNS, 'business_key', DISPLAY_BUSINESS_NAME_COLUMN)
      insert_after(with_display, 'business_keys', BUSINESS_NAMES_COLUMN)
    end

    def each
      return enum_for(:each) unless block_given?

      group_scope.find_in_batches(batch_size: 1_000) do |groups|
        licenses_by_group_id = licenses_for_group_ids(groups.map(&:id))
        groups.each do |group|
          licenses = licenses_by_group_id.fetch(group.id, [])
          yield row_for(group, licenses) if licenses.any?
        end
      end

      fallback_licenses.each_value do |licenses|
        yield fallback_row_for(licenses)
      end
    end

    private

    attr_reader :include_business_names, :latest_only, :sim_locator, :latest_review_status_by_location_id

    def group_scope
      scope = LicensePointGroup.order(:reported_at, :id)
      latest_only ? scope.where(reported_at: AlcoholLicense.maximum(:reported_at)) : scope
    end

    def licenses_for_group_ids(group_ids)
      AlcoholLicense
        .joins(:business, :business_category, :license_category, location: :transformed_location)
        .joins(<<~SQL.squish)
          LEFT JOIN geocoding_results selected_geocoding_results
            ON selected_geocoding_results.transformed_location_id = transformed_locations.id
            AND selected_geocoding_results.selected = 1
        SQL
        .where(license_point_group_id: group_ids)
        .select(
          'alcohol_licenses.id',
          'alcohol_licenses.expires_at',
          'alcohol_licenses.license_point_group_id',
          'alcohol_licenses.business_id',
          'businesses.name AS business_name',
          'business_categories.name AS business_category_name',
          'license_categories.name AS license_category_name',
          'locations.id AS raw_location_internal_id',
          'locations.address_1 AS source_address_1',
          'locations.address_2 AS source_address_2',
          'transformed_locations.id AS transformed_location_internal_id',
          'transformed_locations.address_1 AS normalized_address_1',
          'transformed_locations.building_number AS normalized_building_number',
          'transformed_locations.address_kind AS normalized_address_kind',
          'transformed_locations.address_kind AS address_kind',
          'transformed_locations.address_relation AS normalized_address_relation',
          'transformed_locations.unit_number AS normalized_unit_number',
          'transformed_locations.parcel_number AS normalized_parcel_number',
          'transformed_locations.parcel_region AS normalized_parcel_region',
          'transformed_locations.parcel_cadastral_unit AS normalized_parcel_cadastral_unit',
          'transformed_locations.latitude AS latitude',
          'transformed_locations.longtitude AS longitude',
          'selected_geocoding_results.source AS geocoding_source',
          'selected_geocoding_results.strategy AS geocoding_strategy',
          'selected_geocoding_results.precision AS geocoding_precision',
          'selected_geocoding_results.query AS geocoding_query'
        )
        .order(:license_point_group_id, :id)
        .group_by(&:license_point_group_id)
    end

    def fallback_licenses
      scope = AlcoholLicense
        .joins(:business, :business_category, :license_category, location: :transformed_location)
        .joins(<<~SQL.squish)
          LEFT JOIN geocoding_results selected_geocoding_results
            ON selected_geocoding_results.transformed_location_id = transformed_locations.id
            AND selected_geocoding_results.selected = 1
        SQL
        .where(license_point_group_id: nil)
        .where.not(transformed_locations: { latitude: nil, longtitude: nil })
        .select(
          'alcohol_licenses.id',
          'alcohol_licenses.reported_at',
          'alcohol_licenses.expires_at',
          'alcohol_licenses.location_id',
          'alcohol_licenses.business_id',
          'businesses.name AS business_name',
          'business_categories.name AS business_category_name',
          'license_categories.name AS license_category_name',
          'locations.id AS raw_location_internal_id',
          'locations.address_1 AS source_address_1',
          'locations.address_2 AS source_address_2',
          'transformed_locations.id AS transformed_location_internal_id',
          'transformed_locations.address_1 AS normalized_address_1',
          'transformed_locations.building_number AS normalized_building_number',
          'transformed_locations.address_kind AS normalized_address_kind',
          'transformed_locations.address_kind AS address_kind',
          'transformed_locations.address_relation AS normalized_address_relation',
          'transformed_locations.unit_number AS normalized_unit_number',
          'transformed_locations.parcel_number AS normalized_parcel_number',
          'transformed_locations.parcel_region AS normalized_parcel_region',
          'transformed_locations.parcel_cadastral_unit AS normalized_parcel_cadastral_unit',
          'transformed_locations.latitude AS latitude',
          'transformed_locations.longtitude AS longitude',
          'selected_geocoding_results.source AS geocoding_source',
          'selected_geocoding_results.strategy AS geocoding_strategy',
          'selected_geocoding_results.precision AS geocoding_precision',
          'selected_geocoding_results.query AS geocoding_query'
        )
        .order(:reported_at, :business_id, :location_id, :id)

      scope = scope.where(reported_at: AlcoholLicense.maximum(:reported_at)) if latest_only

      scope.group_by do |license|
        [
          license.reported_at.utc.iso8601,
          license.business_id,
          license.location_id,
          license.latitude,
          license.longitude
        ]
      end
    end

    def row_for(group, licenses)
      representative = representative_license(licenses)
      normalized_location_id = normalized_location_id_for(representative)
      business_names = licenses.map(&:business_name).uniq.sort
      business_keys = business_names.map { |name| DatasetExport::StableId.business_key(name) }.uniq.sort
      business_categories = licenses.map(&:business_category_name).uniq.sort
      license_categories = licenses.map(&:license_category_name).uniq.sort
      license_counts = license_categories.index_with { |category| licenses.count { |license| license.license_category_name == category } }
      retail_count = licenses.count { |license| license.business_category_name == 'detal' }
      gastronomy_count = licenses.count { |license| license.business_category_name == 'gastronomia' }
      sim = sim_locator.locate(group.latitude, group.longitude)
      uncertainty_reasons = licenses.flat_map { |license| Geocoding::LocationUncertainty.reasons(license) }.uniq.sort

      row = {
        'point_id' => DatasetExport::StableId.group_point_id(
          reported_at: group.reported_at,
          latitude: group.latitude,
          longitude: group.longitude,
          normalized_business_name: group.normalized_business_name,
          internal_group_id: group.id
        ),
        'internal_license_point_group_id' => group.id,
        'report_id' => DatasetExport::StableId.report_id(group.reported_at),
        'reported_at' => group.reported_at.utc.iso8601,
        'report_date' => group.reported_at.to_date.iso8601,
        'latitude' => group.latitude,
        'longitude' => group.longitude,
        'crs' => 'EPSG:4326',
        'normalized_location_id' => normalized_location_id,
        'raw_location_ids' => json_array(raw_location_ids(licenses)),
        'display_address' => display_address(representative),
        'address_1' => representative.normalized_address_1,
        'building_number' => representative.normalized_building_number,
        'unit_number' => representative.normalized_unit_number,
        'address_kind' => representative.normalized_address_kind,
        'address_relation' => representative.normalized_address_relation,
        'parcel_number' => representative.normalized_parcel_number,
        'parcel_region' => representative.normalized_parcel_region,
        'parcel_cadastral_unit' => representative.normalized_parcel_cadastral_unit,
        'business_key' => DatasetExport::StableId.business_key(group.normalized_business_name),
        'business_keys' => json_array(business_keys),
        'business_count' => business_names.size,
        'business_id_count' => licenses.map(&:business_id).uniq.size,
        'license_count' => licenses.size,
        'license_categories' => json_array(license_categories),
        'license_count_a' => license_counts.fetch('A', 0),
        'license_count_b' => license_counts.fetch('B', 0),
        'license_count_c' => license_counts.fetch('C', 0),
        'business_categories' => json_array(business_categories),
        'retail_license_count' => retail_count,
        'gastronomy_license_count' => gastronomy_count,
        'retail_flag' => retail_count.positive?,
        'gastronomy_flag' => gastronomy_count.positive?,
        'mixed_flag' => retail_count.positive? && gastronomy_count.positive?,
        'similarity_floor' => group.similarity_floor,
        'geocoding_source' => representative.geocoding_source,
        'geocoding_strategy' => representative.geocoding_strategy,
        'geocoding_precision' => representative.geocoding_precision,
        'geocoding_query' => representative.geocoding_query,
        'location_uncertain' => uncertainty_reasons.any?,
        'location_uncertainty_reasons' => json_array(uncertainty_reasons),
        'latest_review_status' => json_array(latest_review_statuses(licenses)),
        'sim_unit_code' => sim&.fetch(:code),
        'sim_unit_name' => sim&.fetch(:name),
        'district_code' => sim&.fetch(:district_code),
        'district_name' => sim&.fetch(:district),
        'expires_at_max' => licenses.map(&:expires_at).compact.map(&:to_date).max&.iso8601
      }

      if include_business_names
        row[DISPLAY_BUSINESS_NAME_COLUMN] = group.display_business_name
        row[BUSINESS_NAMES_COLUMN] = json_array(business_names)
      end

      row
    end

    def fallback_row_for(licenses)
      representative = representative_license(licenses)
      normalized_location_id = normalized_location_id_for(representative)
      business_names = licenses.map(&:business_name).uniq.sort
      business_keys = business_names.map { |name| DatasetExport::StableId.business_key(name) }.uniq.sort
      business_categories = licenses.map(&:business_category_name).uniq.sort
      license_categories = licenses.map(&:license_category_name).uniq.sort
      license_counts = license_categories.index_with { |category| licenses.count { |license| license.license_category_name == category } }
      retail_count = licenses.count { |license| license.business_category_name == 'detal' }
      gastronomy_count = licenses.count { |license| license.business_category_name == 'gastronomia' }
      sim = sim_locator.locate(representative.latitude, representative.longitude)
      uncertainty_reasons = licenses.flat_map { |license| Geocoding::LocationUncertainty.reasons(license) }.uniq.sort

      row = {
        'point_id' => DatasetExport::StableId.point_id(
          reported_at: representative.reported_at,
          normalized_location_id: normalized_location_id,
          unit_number: representative.normalized_unit_number,
          normalized_business_name: "business:#{representative.business_id}"
        ),
        'internal_license_point_group_id' => nil,
        'report_id' => DatasetExport::StableId.report_id(representative.reported_at),
        'reported_at' => representative.reported_at.utc.iso8601,
        'report_date' => representative.reported_at.to_date.iso8601,
        'latitude' => representative.latitude,
        'longitude' => representative.longitude,
        'crs' => 'EPSG:4326',
        'normalized_location_id' => normalized_location_id,
        'raw_location_ids' => json_array(raw_location_ids(licenses)),
        'display_address' => display_address(representative),
        'address_1' => representative.normalized_address_1,
        'building_number' => representative.normalized_building_number,
        'unit_number' => representative.normalized_unit_number,
        'address_kind' => representative.normalized_address_kind,
        'address_relation' => representative.normalized_address_relation,
        'parcel_number' => representative.normalized_parcel_number,
        'parcel_region' => representative.normalized_parcel_region,
        'parcel_cadastral_unit' => representative.normalized_parcel_cadastral_unit,
        'business_key' => DatasetExport::StableId.business_key(representative.business_name),
        'business_keys' => json_array(business_keys),
        'business_count' => business_names.size,
        'business_id_count' => licenses.map(&:business_id).uniq.size,
        'license_count' => licenses.size,
        'license_categories' => json_array(license_categories),
        'license_count_a' => license_counts.fetch('A', 0),
        'license_count_b' => license_counts.fetch('B', 0),
        'license_count_c' => license_counts.fetch('C', 0),
        'business_categories' => json_array(business_categories),
        'retail_license_count' => retail_count,
        'gastronomy_license_count' => gastronomy_count,
        'retail_flag' => retail_count.positive?,
        'gastronomy_flag' => gastronomy_count.positive?,
        'mixed_flag' => retail_count.positive? && gastronomy_count.positive?,
        'similarity_floor' => 1.0,
        'geocoding_source' => representative.geocoding_source,
        'geocoding_strategy' => representative.geocoding_strategy,
        'geocoding_precision' => representative.geocoding_precision,
        'geocoding_query' => representative.geocoding_query,
        'location_uncertain' => uncertainty_reasons.any?,
        'location_uncertainty_reasons' => json_array(uncertainty_reasons),
        'latest_review_status' => json_array(latest_review_statuses(licenses)),
        'sim_unit_code' => sim&.fetch(:code),
        'sim_unit_name' => sim&.fetch(:name),
        'district_code' => sim&.fetch(:district_code),
        'district_name' => sim&.fetch(:district),
        'expires_at_max' => licenses.map(&:expires_at).compact.map(&:to_date).max&.iso8601
      }

      if include_business_names
        row[DISPLAY_BUSINESS_NAME_COLUMN] = representative.business_name
        row[BUSINESS_NAMES_COLUMN] = json_array(business_names)
      end

      row
    end

    def representative_license(licenses)
      licenses.min_by do |license|
        [
          license.transformed_location_internal_id.to_i,
          license.raw_location_internal_id.to_i,
          license.id.to_i
        ]
      end
    end

    def raw_location_ids(licenses)
      licenses
        .map do |license|
          DatasetExport::StableId.raw_location_id(
            source_address_1: license.source_address_1,
            source_address_2: license.source_address_2
          )
        end
        .uniq
        .sort
    end

    def normalized_location_id_for(license)
      DatasetExport::StableId.normalized_location_id(
        address_1: license.normalized_address_1,
        building_number: license.normalized_building_number,
        address_kind: license.normalized_address_kind,
        address_relation: license.normalized_address_relation,
        unit_number: license.normalized_unit_number,
        parcel_number: license.normalized_parcel_number,
        parcel_region: license.normalized_parcel_region,
        parcel_cadastral_unit: license.normalized_parcel_cadastral_unit
      )
    end

    def display_address(license)
      [
        license.normalized_address_1.presence || license.source_address_1,
        license.normalized_building_number.presence || license.source_address_2
      ].compact.join(' ')
    end

    def latest_review_statuses(licenses)
      licenses
        .filter_map { |license| @latest_review_status_by_location_id[license.transformed_location_internal_id.to_i] }
        .uniq
        .sort
    end

    def build_latest_review_status_by_location_id
      return {} unless defined?(GeocodingReview)

      GeocodingReview
        .order(:transformed_location_id, :reviewed_at, :id)
        .each_with_object({}) do |review, memo|
          memo[review.transformed_location_id] = review.review_status
        end
    end

    def json_array(values)
      JSON.generate(Array(values).compact)
    end

    def insert_after(columns, after, new_column)
      index = columns.index(after)
      columns.dup.insert(index + 1, new_column)
    end
  end
end
