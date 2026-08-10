require 'time'
require 'json'

require 'dataset_export/stable_id'

module DatasetExport
  class LocationRows
    COLUMNS = %w[
      raw_location_id
      internal_location_ids
      source_address_1
      source_address_2
      normalized_location_id
      license_count
      first_reported_at
      last_reported_at
    ].freeze

    def initialize(latest_only: false)
      @latest_only = latest_only
    end

    def columns
      COLUMNS
    end

    def each
      return enum_for(:each) unless block_given?

      rows.each { |row| yield(row) }
    end

    private

    attr_reader :latest_only

    def rows
      grouped_locations.values.map { |locations| row_for(locations) }.sort_by { |row| row.fetch('raw_location_id') }
    end

    def grouped_locations
      scope.each_with_object({}) do |location, memo|
        raw_location_id = raw_location_id(location)
        memo[raw_location_id] ||= []
        memo[raw_location_id] << location
      end
    end

    def row_for(locations)
      representative = locations.min_by(&:id)
      {
        'raw_location_id' => raw_location_id(representative),
        'internal_location_ids' => internal_location_ids(locations),
        'source_address_1' => representative.address_1,
        'source_address_2' => representative.address_2,
        'normalized_location_id' => normalized_location_id(representative),
        'license_count' => locations.sum { |location| location.license_count.to_i },
        'first_reported_at' => timestamp(locations.map(&:first_reported_at).compact.min),
        'last_reported_at' => timestamp(locations.map(&:last_reported_at).compact.max)
      }
    end

    def scope
      relation = Location
        .joins(:alcohol_licenses)
        .left_joins(:transformed_location)
        .select(
          'locations.id',
          'locations.address_1',
          'locations.address_2',
          'transformed_locations.address_1 AS normalized_address_1',
          'transformed_locations.building_number AS normalized_building_number',
          'transformed_locations.address_kind AS normalized_address_kind',
          'transformed_locations.address_relation AS normalized_address_relation',
          'transformed_locations.unit_number AS normalized_unit_number',
          'transformed_locations.parcel_number AS normalized_parcel_number',
          'transformed_locations.parcel_region AS normalized_parcel_region',
          'transformed_locations.parcel_cadastral_unit AS normalized_parcel_cadastral_unit',
          'COUNT(alcohol_licenses.id) AS license_count',
          'MIN(alcohol_licenses.reported_at) AS first_reported_at',
          'MAX(alcohol_licenses.reported_at) AS last_reported_at'
        )
        .group(
          'locations.id',
          'locations.address_1',
          'locations.address_2',
          'transformed_locations.address_1',
          'transformed_locations.building_number',
          'transformed_locations.address_kind',
          'transformed_locations.address_relation',
          'transformed_locations.unit_number',
          'transformed_locations.parcel_number',
          'transformed_locations.parcel_region',
          'transformed_locations.parcel_cadastral_unit'
        )
        .order('locations.id ASC')

      return relation unless latest_only

      relation.where(alcohol_licenses: { reported_at: AlcoholLicense.maximum(:reported_at) })
    end

    def raw_location_id(location)
      DatasetExport::StableId.raw_location_id(
        source_address_1: location.address_1,
        source_address_2: location.address_2
      )
    end

    def internal_location_ids(locations)
      JSON.generate(locations.map(&:id).sort)
    end

    def normalized_location_id(location)
      return unless location.normalized_address_1.present?

      DatasetExport::StableId.normalized_location_id(
        address_1: location.normalized_address_1,
        building_number: location.normalized_building_number,
        address_kind: location.normalized_address_kind,
        address_relation: location.normalized_address_relation,
        unit_number: location.normalized_unit_number,
        parcel_number: location.normalized_parcel_number,
        parcel_region: location.normalized_parcel_region,
        parcel_cadastral_unit: location.normalized_parcel_cadastral_unit
      )
    end

    def timestamp(value)
      return if value.blank?
      return value.utc.iso8601 if value.respond_to?(:utc)

      Time.find_zone!('UTC').parse(value.to_s).utc.iso8601
    end
  end
end
