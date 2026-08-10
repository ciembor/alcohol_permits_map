require 'dataset_export/source_file_index'
require 'dataset_export/license_identifiers'
require 'dataset_export/stable_id'
require 'sim/locator'

module DatasetExport
  class LicenseRows
    BASE_COLUMNS = %w[
      license_id
      internal_license_id
      report_id
      reported_at
      report_date
      expires_at
      business_category
      license_category
      license_category_description
      business_key
      raw_location_id
      normalized_location_id
      point_id
      source_address_1
      source_address_2
      source_file_id
      source_row_number
      geocoded
      latitude
      longitude
      sim_unit_code
      sim_unit_name
      district_code
      district_name
    ].freeze

    BUSINESS_NAME_COLUMN = 'business_name'.freeze

    def initialize(source_file_rows: [], include_business_names: false, latest_only: false, sim_locator: Sim::Locator.new)
      @source_file_index = DatasetExport::SourceFileIndex.new(source_file_rows)
      @include_business_names = include_business_names
      @latest_only = latest_only
      @sim_locator = sim_locator
      @identifiers = DatasetExport::LicenseIdentifiers.new
    end

    def columns
      return BASE_COLUMNS unless include_business_names

      insert_after(BASE_COLUMNS, 'business_key', BUSINESS_NAME_COLUMN)
    end

    def each
      return enum_for(:each) unless block_given?

      scope.find_each(batch_size: 2_000) do |license|
        yield row_for(license)
      end
    end

    private

    attr_reader :source_file_index, :include_business_names, :latest_only, :sim_locator, :identifiers

    def scope
      relation = AlcoholLicense
        .joins(:business, :business_category, :license_category, :location)
        .left_joins(:license_point_group)
        .left_joins(location: :transformed_location)
        .select(
          'alcohol_licenses.id',
          'alcohol_licenses.business_id',
          'alcohol_licenses.reported_at',
          'alcohol_licenses.expires_at',
          'alcohol_licenses.license_point_group_id',
          'businesses.name AS business_name',
          'business_categories.name AS business_category_name',
          'license_categories.name AS license_category_name',
          'license_categories.description AS license_category_description',
          'locations.address_1 AS source_address_1',
          'locations.address_2 AS source_address_2',
          'transformed_locations.address_1 AS normalized_address_1',
          'transformed_locations.building_number AS normalized_building_number',
          'transformed_locations.address_kind AS normalized_address_kind',
          'transformed_locations.address_relation AS normalized_address_relation',
          'transformed_locations.unit_number AS normalized_unit_number',
          'transformed_locations.parcel_number AS normalized_parcel_number',
          'transformed_locations.parcel_region AS normalized_parcel_region',
          'transformed_locations.parcel_cadastral_unit AS normalized_parcel_cadastral_unit',
          'transformed_locations.latitude AS latitude',
          'transformed_locations.longtitude AS longitude',
          'license_point_groups.latitude AS group_latitude',
          'license_point_groups.longitude AS group_longitude',
          'license_point_groups.normalized_business_name AS group_normalized_business_name'
        )
        .order('alcohol_licenses.reported_at ASC, alcohol_licenses.id ASC')

      latest_only ? relation.where(reported_at: AlcoholLicense.maximum(:reported_at)) : relation
    end

    def row_for(license)
      normalized_location_id = identifiers.normalized_location_id(license)
      latitude = license.latitude
      longitude = license.longitude
      sim = locate(latitude, longitude)

      row = {
        'license_id' => identifiers.license_id(license),
        'internal_license_id' => license.id,
        'report_id' => DatasetExport::StableId.report_id(license.reported_at),
        'reported_at' => license.reported_at.utc.iso8601,
        'report_date' => license.reported_at.to_date.iso8601,
        'expires_at' => license.expires_at&.to_date&.iso8601,
        'business_category' => license.business_category_name,
        'license_category' => license.license_category_name,
        'license_category_description' => license.license_category_description,
        'business_key' => DatasetExport::StableId.business_key(license.business_name),
        'raw_location_id' => identifiers.raw_location_id(license),
        'normalized_location_id' => normalized_location_id,
        'point_id' => identifiers.point_id(license, normalized_location_id: normalized_location_id),
        'source_address_1' => license.source_address_1,
        'source_address_2' => license.source_address_2,
        'source_file_id' => source_file_index.source_file_id(
          reported_at: license.reported_at,
          business_category: license.business_category_name,
          license_category: license.license_category_name
        ),
        'source_row_number' => nil,
        'geocoded' => geocoded?(latitude, longitude),
        'latitude' => latitude,
        'longitude' => longitude,
        'sim_unit_code' => sim&.fetch(:code),
        'sim_unit_name' => sim&.fetch(:name),
        'district_code' => sim&.fetch(:district_code),
        'district_name' => sim&.fetch(:district)
      }

      row[BUSINESS_NAME_COLUMN] = license.business_name if include_business_names
      row
    end

    def locate(latitude, longitude)
      return unless geocoded?(latitude, longitude)

      sim_locator.locate(latitude, longitude)
    end

    def geocoded?(latitude, longitude)
      latitude.present? && longitude.present?
    end

    def insert_after(columns, after, new_column)
      index = columns.index(after)
      columns.dup.insert(index + 1, new_column)
    end
  end
end
