require 'dataset_export/stable_id'

module DatasetExport
  class LicenseIdentifiers
    def initialize
      @natural_key_counts = Hash.new(0)
      @group_raw_location_ids = build_group_raw_location_ids
    end

    def license_id(license)
      key = natural_key_for(license)
      natural_key_counts[key] += 1

      DatasetExport::StableId.license_id(
        reported_at: license.reported_at,
        business_category: license.business_category_name,
        license_category: license.license_category_name,
        business_name: license.business_name,
        source_address_1: license.source_address_1,
        source_address_2: license.source_address_2,
        expires_at: license.expires_at,
        occurrence_index: natural_key_counts[key]
      )
    end

    def raw_location_id(license)
      DatasetExport::StableId.raw_location_id(
        source_address_1: license.source_address_1,
        source_address_2: license.source_address_2
      )
    end

    def normalized_location_id(license)
      return unless license.normalized_address_1.present?

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

    def point_id(license, normalized_location_id: nil)
      return unless geocoded?(license)

      if license.license_point_group_id.present?
        return DatasetExport::StableId.group_point_id(
          reported_at: license.reported_at,
          latitude: license.group_latitude,
          longitude: license.group_longitude,
          normalized_business_name: license.group_normalized_business_name,
          raw_location_ids: raw_location_ids_for_group(license.license_point_group_id)
        )
      end

      normalized_location_id ||= self.normalized_location_id(license)
      return unless normalized_location_id.present?

      DatasetExport::StableId.point_id(
        reported_at: license.reported_at,
        normalized_location_id: normalized_location_id,
        unit_number: license.normalized_unit_number,
        normalized_business_name: license.group_normalized_business_name.presence || license.business_name
      )
    end

    def geocoded?(license)
      license.latitude.present? && license.longitude.present?
    end

    private

    attr_reader :natural_key_counts, :group_raw_location_ids

    def raw_location_ids_for_group(group_id)
      group_raw_location_ids.fetch(group_id, [])
    end

    def build_group_raw_location_ids
      rows = AlcoholLicense
        .joins(:location)
        .where.not(license_point_group_id: nil)
        .pluck('alcohol_licenses.license_point_group_id', 'locations.address_1', 'locations.address_2')

      rows.each_with_object(Hash.new { |hash, key| hash[key] = [] }) do |(group_id, address_1, address_2), memo|
        memo[group_id] << DatasetExport::StableId.raw_location_id(
          source_address_1: address_1,
          source_address_2: address_2
        )
      end.transform_values { |ids| ids.uniq.sort }
    end

    def natural_key_for(license)
      [
        license.reported_at.utc.iso8601,
        license.business_category_name.to_s.strip.squeeze(' '),
        license.license_category_name.to_s.strip.squeeze(' '),
        license.business_name.to_s.strip.squeeze(' '),
        license.source_address_1.to_s.strip.squeeze(' '),
        license.source_address_2.to_s.strip.squeeze(' '),
        license.expires_at&.to_date&.iso8601.to_s
      ]
    end
  end
end
