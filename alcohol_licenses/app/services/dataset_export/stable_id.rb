require 'date'
require 'digest'
require 'time'

module DatasetExport
  class StableId
    class << self
      def report_id(reported_at)
        "report-#{timestamp_slug(reported_at)}"
      end

      def source_file_id(reported_at:, business_category:, license_category:, file_format:)
        scoped_hash_id(
          'source-file',
          reported_at: normalize_time(reported_at),
          business_category: normalize_value(business_category),
          license_category: normalize_value(license_category),
          file_format: normalize_value(file_format)
        )
      end

      def license_id(reported_at:, business_category:, license_category:, business_name:, source_address_1:, source_address_2:, expires_at:, occurrence_index: nil)
        scoped_hash_id(
          'license',
          reported_at: normalize_time(reported_at),
          business_category: normalize_value(business_category),
          license_category: normalize_value(license_category),
          business_name: normalize_value(business_name),
          source_address_1: normalize_value(source_address_1),
          source_address_2: normalize_value(source_address_2),
          expires_at: normalize_date(expires_at),
          occurrence_index: normalize_value(occurrence_index)
        )
      end

      def raw_location_id(source_address_1:, source_address_2:)
        scoped_hash_id(
          'raw-location',
          source_address_1: normalize_value(source_address_1),
          source_address_2: normalize_value(source_address_2)
        )
      end

      def normalized_location_id(address_1:, building_number:, address_kind:, address_relation:, unit_number:, parcel_number:, parcel_region:, parcel_cadastral_unit:)
        scoped_hash_id(
          'normalized-location',
          address_1: normalize_value(address_1),
          building_number: normalize_value(building_number),
          address_kind: normalize_value(address_kind),
          address_relation: normalize_value(address_relation),
          unit_number: normalize_value(unit_number),
          parcel_number: normalize_value(parcel_number),
          parcel_region: normalize_value(parcel_region),
          parcel_cadastral_unit: normalize_value(parcel_cadastral_unit)
        )
      end

      def business_key(business_name)
        scoped_hash_id('business', business_name: normalize_value(business_name))
      end

      def address_correction_id(raw_location_id:, source_raw_location_id:, corrected_address_1:, corrected_address_2:, source:, method:)
        scoped_hash_id(
          'address-correction',
          raw_location_id: normalize_value(raw_location_id),
          source_raw_location_id: normalize_value(source_raw_location_id),
          corrected_address_1: normalize_value(corrected_address_1),
          corrected_address_2: normalize_value(corrected_address_2),
          source: normalize_value(source),
          method: normalize_value(method)
        )
      end

      def geocoding_result_id(normalized_location_id:, source:, strategy:, query:)
        scoped_hash_id(
          'geocoding-result',
          normalized_location_id: normalize_value(normalized_location_id),
          source: normalize_value(source),
          strategy: normalize_value(strategy),
          query: normalize_value(query)
        )
      end

      def geocoding_review_id(normalized_location_id:, signal_category:, review_status:, reviewed_at:, original_latitude:, original_longitude:, manual_latitude:, manual_longitude:, occurrence_index: nil)
        scoped_hash_id(
          'geocoding-review',
          normalized_location_id: normalize_value(normalized_location_id),
          signal_category: normalize_value(signal_category),
          review_status: normalize_value(review_status),
          reviewed_at: normalize_time(reviewed_at),
          original_latitude: normalize_coordinate(original_latitude),
          original_longitude: normalize_coordinate(original_longitude),
          manual_latitude: normalize_coordinate(manual_latitude),
          manual_longitude: normalize_coordinate(manual_longitude),
          occurrence_index: normalize_value(occurrence_index)
        )
      end

      def point_id(reported_at:, normalized_location_id:, unit_number:, normalized_business_name:)
        scoped_hash_id(
          'point',
          reported_at: normalize_time(reported_at),
          normalized_location_id: normalize_value(normalized_location_id),
          unit_number: normalize_value(unit_number),
          normalized_business_name: normalize_value(normalized_business_name)
        )
      end

      def group_point_id(reported_at:, latitude:, longitude:, normalized_business_name:, unit_number: nil, internal_group_id: nil)
        scoped_hash_id(
          'point',
          reported_at: normalize_time(reported_at),
          latitude: normalize_coordinate(latitude),
          longitude: normalize_coordinate(longitude),
          unit_number: normalize_value(unit_number),
          internal_group_id: normalize_value(internal_group_id),
          normalized_business_name: normalize_value(normalized_business_name)
        )
      end

      def scoped_hash_id(scope, values)
        "#{scope}-#{digest(canonical_payload(values))}"
      end

      private

      def digest(payload)
        Digest::SHA256.hexdigest(payload)[0, 16]
      end

      def canonical_payload(values)
        values
          .sort_by { |key, _value| key.to_s }
          .map { |key, value| "#{key}=#{value}" }
          .join("\n")
      end

      def timestamp_slug(value)
        normalize_time(value).tr(':', '-')
      end

      def normalize_time(value)
        case value
        when Time
          value.utc.iso8601
        when DateTime
          value.to_time.utc.iso8601
        when Date
          Time.utc(value.year, value.month, value.day).iso8601
        else
          Time.parse(value.to_s).utc.iso8601
        end
      end

      def normalize_date(value)
        return '' if value.nil? || value.to_s.strip.empty?
        return value.to_date.iso8601 if value.respond_to?(:to_date)

        Date.parse(value.to_s).iso8601
      end

      def normalize_value(value)
        value.to_s.strip.squeeze(' ')
      end

      def normalize_coordinate(value)
        return '' if value.nil? || value.to_s.strip.empty?

        format('%.12f', value.to_f)
      end
    end
  end
end
