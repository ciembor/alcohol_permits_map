class GeocodingReviewsController < ApplicationController
  before_action :ensure_local_request

  def index
    @review_i18n = I18n.t('geocoding_reviews.js')
  end

  def categories
    finder = candidate_finder

    render json: {
      categories: finder.categories
    }
  end

  def next
    candidate = candidate_finder.next_candidate(
      category: params[:category]
    )

    render json: {
      candidate: candidate
    }
  end

  def create
    location = TransformedLocation.find(params[:transformed_location_id])
    result = nil
    status = review_status

    TransformedLocation.transaction do
      if status == 'corrected'
        result = create_manual_geocoding_result(location)
        GeocodingResult.where(transformed_location_id: location.id).update_all(selected: false)
        result.update!(selected: true)
        location.use_geocoding_result!(result)
      end

      GeocodingReview.create!(
        transformed_location: location,
        signal_category: params.require(:signal_category),
        review_status: status,
        reviewed_by: params[:reviewed_by].presence,
        original_latitude: params[:original_latitude],
        original_longitude: params[:original_longitude],
        manual_latitude: params[:manual_latitude].presence,
        manual_longitude: params[:manual_longitude].presence,
        selected_geocoding_result_id: params[:selected_geocoding_result_id].presence,
        manual_geocoding_result_id: result&.id,
        quality_signals: Array(params[:quality_signals]),
        note: params[:note].presence,
        sim_circle_within_area: sim_review_area_containment.within_area?(
          GeocodingReview.new(transformed_location: location, review_status: status)
        ),
        reviewed_at: Time.current
      )
    end

    render json: {
      ok: true,
      manual_geocoding_result_id: result&.id
    }
  end

  private

  def ensure_local_request
    return if Rails.env.development? || request.local?

    head :not_found
  end

  def candidate_finder
    @candidate_finder ||= GeocodingReviewCandidateFinder.new
  end

  def review_status
    status = params.require(:review_status)
    return status if GeocodingReview::STATUSES.include?(status)

    raise ActionController::BadRequest, "Unsupported review_status: #{status}"
  end

  def create_manual_geocoding_result(location)
    latitude = Float(params.require(:manual_latitude))
    longitude = Float(params.require(:manual_longitude))
    source_label = params[:manual_source].presence || 'manual'

    GeocodingResult.create!(
      transformed_location: location,
      source: 'manual_review',
      strategy: 'manual_pin',
      query: [
        source_label,
        latitude.round(7),
        longitude.round(7),
        Time.current.iso8601
      ].join(' | '),
      latitude: latitude,
      longitude: longitude,
      confidence: 1.0,
      precision: params[:manual_precision].presence || 'manual/verified_point',
      selected: false,
      raw_response: {
        source: source_label,
        note: params[:note].presence,
        selected_geocoding_result_id: params[:selected_geocoding_result_id].presence
      }.to_json
    )
  end

  def sim_review_area_containment
    @sim_review_area_containment ||= Sim::ReviewAreaContainment.new
  end
end
