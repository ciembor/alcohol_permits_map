require 'dataset_export/stable_id'

module DatasetExport
  class GeocodingResultRows
    COLUMNS = %w[
      geocoding_result_id
      normalized_location_id
      source
      strategy
      query
      latitude
      longitude
      crs
      confidence
      precision
      selected
    ].freeze

    EXCLUDED_SOURCES = %w[google].freeze

    def initialize(latest_only: false)
      @latest_only = latest_only
      @latest_reported_at = AlcoholLicense.maximum(:reported_at) if latest_only
    end

    def columns
      COLUMNS
    end

    def each
      return enum_for(:each) unless block_given?

      scope.find_each(batch_size: 1_000) do |result|
        normalized_location_id = normalized_location_id_for(result.transformed_location)

        yield({
          'geocoding_result_id' => DatasetExport::StableId.geocoding_result_id(
            normalized_location_id: normalized_location_id,
            source: result.source,
            strategy: result.strategy,
            query: result.query
          ),
          'normalized_location_id' => normalized_location_id,
          'source' => result.source,
          'strategy' => result.strategy,
          'query' => result.query,
          'latitude' => result.latitude,
          'longitude' => result.longitude,
          'crs' => geocoded?(result) ? 'EPSG:4326' : nil,
          'confidence' => result.confidence,
          'precision' => result.precision,
          'selected' => result.selected
        })
      end
    end

    private

    attr_reader :latest_only, :latest_reported_at

    def scope
      relation = GeocodingResult
        .includes(:transformed_location)
        .where.not(source: EXCLUDED_SOURCES)
        .order(:transformed_location_id, :id)

      return relation unless latest_only

      relation
        .joins(transformed_location: { locations: :alcohol_licenses })
        .where(alcohol_licenses: { reported_at: latest_reported_at })
        .distinct
    end

    def normalized_location_id_for(location)
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

    def geocoded?(result)
      result.latitude.present? && result.longitude.present?
    end
  end
end
