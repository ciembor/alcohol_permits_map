require 'json'
require 'time'

require 'dataset_export/geocoding_result_rows'
require 'dataset_export/stable_id'
require 'geocoding/location_uncertainty'

module DatasetExport
  class NormalizedLocationRows
    COLUMNS = %w[
      normalized_location_id
      address_1
      building_number
      unit_number
      address_kind
      address_relation
      normalization_input_address_2
      parcel_number
      parcel_region
      parcel_cadastral_unit
      same_as
      latitude
      longitude
      crs
      selected_geocoding_result_id
      selected_geocoding_source
      selected_geocoding_strategy
      selected_geocoding_precision
      location_uncertain
      location_uncertainty_reasons
      raw_location_count
      license_count
      first_reported_at
      last_reported_at
    ].freeze

    def initialize(latest_only: false)
      @latest_only = latest_only
      @latest_reported_at = AlcoholLicense.maximum(:reported_at) if latest_only
    end

    def columns
      COLUMNS
    end

    def each
      return enum_for(:each) unless block_given?

      scope.find_each(batch_size: 1_000) do |location|
        yield row_for(location)
      end
    end

    private

    attr_reader :latest_only, :latest_reported_at

    def scope
      relation = TransformedLocation.order(:id)
      return relation unless latest_only

      relation
        .joins(locations: :alcohol_licenses)
        .where(alcohol_licenses: { reported_at: latest_reported_at })
        .distinct
    end

    def row_for(location)
      metrics = metrics_for(location)
      uncertainty_reasons = Geocoding::LocationUncertainty.reasons(uncertainty_payload(location))

      {
        'normalized_location_id' => normalized_location_id(location),
        'address_1' => location.address_1,
        'building_number' => location.building_number,
        'unit_number' => location.unit_number,
        'address_kind' => location.address_kind,
        'address_relation' => location.address_relation,
        'normalization_input_address_2' => location.raw_address_2,
        'parcel_number' => location.parcel_number,
        'parcel_region' => location.parcel_region,
        'parcel_cadastral_unit' => location.parcel_cadastral_unit,
        'same_as' => location.same_as,
        'latitude' => location.latitude,
        'longitude' => location.longtitude,
        'crs' => geocoded?(location) ? 'EPSG:4326' : nil,
        'selected_geocoding_result_id' => selected_geocoding_result_id(location),
        'selected_geocoding_source' => location.selected_geocoding_source,
        'selected_geocoding_strategy' => location.selected_geocoding_strategy,
        'selected_geocoding_precision' => location.selected_geocoding_precision,
        'location_uncertain' => uncertainty_reasons.any?,
        'location_uncertainty_reasons' => JSON.generate(uncertainty_reasons),
        'raw_location_count' => metrics.fetch(:raw_location_count),
        'license_count' => metrics.fetch(:license_count),
        'first_reported_at' => timestamp(metrics.fetch(:first_reported_at)),
        'last_reported_at' => timestamp(metrics.fetch(:last_reported_at))
      }
    end

    def metrics_for(location)
      locations = scoped_locations_for(location).to_a
      location_ids = locations.map(&:id)
      licenses = AlcoholLicense.where(location_id: location_ids)
      licenses = licenses.where(reported_at: latest_reported_at) if latest_only

      {
        raw_location_count: raw_location_ids(locations).size,
        license_count: licenses.count,
        first_reported_at: licenses.minimum(:reported_at),
        last_reported_at: licenses.maximum(:reported_at)
      }
    end

    def scoped_locations_for(location)
      locations = location.locations.joins(:alcohol_licenses)
      locations = locations.where(alcohol_licenses: { reported_at: latest_reported_at }) if latest_only
      locations.distinct
    end

    def raw_location_ids(locations)
      locations.map do |location|
        DatasetExport::StableId.raw_location_id(
          source_address_1: location.address_1,
          source_address_2: location.address_2
        )
      end.uniq
    end

    def normalized_location_id(location)
      DatasetExport::StableId.normalized_location_id(
        address_1: location.address_1,
        building_number: location.building_number,
        address_kind: location.address_kind,
        address_relation: location.address_relation,
        unit_number: location.unit_number,
        parcel_number: location.parcel_number,
        parcel_region: location.parcel_region,
        parcel_cadastral_unit: location.parcel_cadastral_unit
      )
    end

    def selected_geocoding_result_id(location)
      return if location.selected_geocoding_result_id.blank?

      result = GeocodingResult.find_by(id: location.selected_geocoding_result_id)
      return if result.nil?
      return if DatasetExport::GeocodingResultRows::EXCLUDED_SOURCES.include?(result.source)

      DatasetExport::StableId.geocoding_result_id(
        normalized_location_id: normalized_location_id(location),
        source: result.source,
        strategy: result.strategy,
        query: result.query
      )
    end

    def uncertainty_payload(location)
      {
        geocoding_source: location.selected_geocoding_source,
        geocoding_strategy: location.selected_geocoding_strategy,
        geocoding_precision: location.selected_geocoding_precision,
        address_kind: location.address_kind
      }
    end

    def geocoded?(location)
      location.latitude.present? && location.longtitude.present?
    end

    def timestamp(value)
      return if value.blank?
      return value.utc.iso8601 if value.respond_to?(:utc)

      Time.find_zone!('UTC').parse(value.to_s).utc.iso8601
    end
  end
end
