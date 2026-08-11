require 'dataset_export/license_identifiers'

module DatasetExport
  class MembershipRows
    COLUMNS = %w[
      point_id
      license_id
      report_id
      membership_method
    ].freeze

    def initialize(latest_only: false)
      @latest_only = latest_only
      @identifiers = DatasetExport::LicenseIdentifiers.new
    end

    def columns
      COLUMNS
    end

    def each
      return enum_for(:each) unless block_given?

      scope.find_each(batch_size: 2_000) do |license|
        normalized_location_id = identifiers.normalized_location_id(license)
        yield({
          'point_id' => identifiers.point_id(license, normalized_location_id: normalized_location_id),
          'license_id' => identifiers.license_id(license),
          'report_id' => DatasetExport::StableId.report_id(license.reported_at),
          'membership_method' => membership_method(license)
        })
      end
    end

    private

    attr_reader :latest_only, :identifiers

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

    def membership_method(license)
      return 'not_geocoded' unless identifiers.geocoded?(license)
      return 'license_point_group' if license.license_point_group_id.present?

      'fallback_business_location'
    end
  end
end
