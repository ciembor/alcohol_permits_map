require 'json'

require 'dataset_export/geocoding_result_rows'
require 'dataset_export/stable_id'

module DatasetExport
  class GeocodingReviewRows
    COLUMNS = %w[
      review_id
      normalized_location_id
      signal_category
      review_status
      original_latitude
      original_longitude
      manual_latitude
      manual_longitude
      selected_geocoding_result_id
      manual_geocoding_result_id
      quality_signals
      sim_circle_within_area
      reviewed_at
    ].freeze

    def initialize(latest_only: false)
      @latest_only = latest_only
      @latest_reported_at = AlcoholLicense.maximum(:reported_at) if latest_only
      @natural_key_counts = Hash.new(0)
    end

    def columns
      COLUMNS
    end

    def each
      return enum_for(:each) unless block_given?

      scope.find_each(batch_size: 500) do |review|
        normalized_location_id = normalized_location_id_for(review.transformed_location)
        selected_geocoding_result_id = public_geocoding_result_id(review.selected_geocoding_result)
        manual_geocoding_result_id = public_geocoding_result_id(review.manual_geocoding_result)

        yield({
          'review_id' => review_id_for(review, normalized_location_id),
          'normalized_location_id' => normalized_location_id,
          'signal_category' => review.signal_category,
          'review_status' => review.review_status,
          'original_latitude' => review.original_latitude,
          'original_longitude' => review.original_longitude,
          'manual_latitude' => review.manual_latitude,
          'manual_longitude' => review.manual_longitude,
          'selected_geocoding_result_id' => selected_geocoding_result_id,
          'manual_geocoding_result_id' => manual_geocoding_result_id,
          'quality_signals' => JSON.generate(Array(review.quality_signals).compact),
          'sim_circle_within_area' => review.sim_circle_within_area,
          'reviewed_at' => review.reviewed_at.utc.iso8601
        })
      end
    end

    private

    attr_reader :latest_only, :latest_reported_at, :natural_key_counts

    def scope
      relation = GeocodingReview
        .includes(:transformed_location, :selected_geocoding_result, :manual_geocoding_result)
        .order(:transformed_location_id, :reviewed_at, :id)

      return relation unless latest_only

      relation
        .joins(transformed_location: { locations: :alcohol_licenses })
        .where(alcohol_licenses: { reported_at: latest_reported_at })
        .distinct
    end

    def review_id_for(review, normalized_location_id)
      key = natural_key_for(review, normalized_location_id)
      natural_key_counts[key] += 1

      DatasetExport::StableId.geocoding_review_id(
        normalized_location_id: normalized_location_id,
        signal_category: review.signal_category,
        review_status: review.review_status,
        reviewed_at: review.reviewed_at,
        original_latitude: review.original_latitude,
        original_longitude: review.original_longitude,
        manual_latitude: review.manual_latitude,
        manual_longitude: review.manual_longitude,
        occurrence_index: natural_key_counts[key]
      )
    end

    def natural_key_for(review, normalized_location_id)
      [
        normalized_location_id,
        review.signal_category,
        review.review_status,
        review.reviewed_at.utc.iso8601,
        review.original_latitude,
        review.original_longitude,
        review.manual_latitude,
        review.manual_longitude
      ]
    end

    def public_geocoding_result_id(result)
      return if result.nil?
      return if DatasetExport::GeocodingResultRows::EXCLUDED_SOURCES.include?(result.source)

      DatasetExport::StableId.geocoding_result_id(
        normalized_location_id: normalized_location_id_for(result.transformed_location),
        source: result.source,
        strategy: result.strategy,
        query: result.query
      )
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

  end
end
