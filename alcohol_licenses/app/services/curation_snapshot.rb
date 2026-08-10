require 'json'

class CurationSnapshot
  DEFAULT_PATH = Rails.root.join('db/curation/current.json').freeze
  TRANSFORMED_LOCATION_COLUMNS = %w[
    address_1
    building_number
    address_kind
    address_relation
    unit_number
    parcel_number
    parcel_region
    parcel_cadastral_unit
    raw_address_2
    same_as
  ].freeze
  CURATED_GEOCODING_SOURCES = %w[
    manual_geo_completion
    manual_geo_derivation
    manual_street_audit
  ].freeze
  MANUAL_REVIEW_STRATEGIES = %w[
    manual_pin
  ].freeze

  def self.export!(path: DEFAULT_PATH)
    new(path: path).export!
  end

  def self.import!(path: DEFAULT_PATH)
    new(path: path).import!
  end

  def self.import_address_corrections!(path: DEFAULT_PATH)
    new(path: path).import_address_corrections!
  end

  def self.import_geocoding_decisions!(path: DEFAULT_PATH)
    new(path: path).import_geocoding_decisions!
  end

  def initialize(path: DEFAULT_PATH)
    @path = Pathname(path)
  end

  def export!
    FileUtils.mkdir_p(path.dirname)
    path.write(JSON.pretty_generate(snapshot) + "\n")

    counts
  end

  def import!
    address_corrections = import_address_corrections!
    geocoding_decisions = import_geocoding_decisions!

    {
      address_corrections: address_corrections,
      selected_geocoding_results: geocoding_decisions.fetch(:selected_geocoding_results),
      geocoding_reviews: geocoding_decisions.fetch(:geocoding_reviews)
    }
  end

  def import_address_corrections!
    import_address_corrections(payload.fetch('address_corrections', []))
  end

  def import_geocoding_decisions!
    {
      selected_geocoding_results: import_selected_geocoding_results(payload.fetch('selected_geocoding_results', [])),
      geocoding_reviews: import_geocoding_reviews(payload.fetch('geocoding_reviews', []))
    }
  end

  private

  attr_reader :path

  def payload
    @payload ||= JSON.parse(path.read)
  end

  def snapshot
    {
      'metadata' => {
        'format' => 'krakow-alcohol-licenses-curation-snapshot',
        'version' => 2,
        'exported_at' => Time.current.utc.iso8601,
        'notes' => 'Curated address corrections, manual/audit geocoding decisions, and geocoding review outcomes. Automatic selected geocoding results and raw geocoder responses are intentionally excluded.'
      },
      'address_corrections' => address_corrections,
      'selected_geocoding_results' => selected_geocoding_results,
      'geocoding_reviews' => geocoding_reviews
    }
  end

  def counts
    {
      address_corrections: AddressCorrection.count,
      selected_geocoding_results: selected_geocoding_results.size,
      geocoding_reviews: GeocodingReview.count
    }
  end

  def address_corrections
    AddressCorrection.includes(:location, :source_location).order(:id).map do |correction|
      {
        'location' => raw_location_identity(correction.location),
        'source_location' => raw_location_identity(correction.source_location),
        'corrected_address_1' => correction.corrected_address_1,
        'corrected_address_2' => correction.corrected_address_2,
        'source' => correction.source,
        'method' => correction.method,
        'confidence' => correction.confidence,
        'selected' => correction.selected,
        'evidence' => correction.evidence,
        'created_at' => iso8601(correction.created_at),
        'updated_at' => iso8601(correction.updated_at)
      }
    end
  end

  def selected_geocoding_results
    GeocodingResult
      .where(id: curated_geocoding_result_ids)
      .includes(:transformed_location)
      .order(:transformed_location_id, :id)
      .map do |result|
        {
          'transformed_location' => transformed_location_identity(result.transformed_location),
          'result' => geocoding_result_payload(result)
        }
      end
  end

  def curated_geocoding_result_ids
    manual_source_ids = GeocodingResult
      .where(source: CURATED_GEOCODING_SOURCES)
      .pluck(:id)
    manual_pin_ids = GeocodingResult
      .where(source: 'manual_review', strategy: MANUAL_REVIEW_STRATEGIES)
      .pluck(:id)
    review_result_ids = GeocodingReview
      .where.not(selected_geocoding_result_id: nil)
      .pluck(:selected_geocoding_result_id)
    review_manual_result_ids = GeocodingReview
      .where.not(manual_geocoding_result_id: nil)
      .pluck(:manual_geocoding_result_id)

    (manual_source_ids + manual_pin_ids + review_result_ids + review_manual_result_ids).uniq
  end

  def geocoding_reviews
    GeocodingReview
      .includes(:transformed_location, :selected_geocoding_result, :manual_geocoding_result)
      .order(:transformed_location_id, :reviewed_at, :id)
      .map do |review|
        {
          'transformed_location' => transformed_location_identity(review.transformed_location),
          'signal_category' => review.signal_category,
          'review_status' => review.review_status,
          'original_latitude' => review.original_latitude,
          'original_longitude' => review.original_longitude,
          'manual_latitude' => review.manual_latitude,
          'manual_longitude' => review.manual_longitude,
          'selected_geocoding_result' => geocoding_result_payload(review.selected_geocoding_result),
          'manual_geocoding_result' => geocoding_result_payload(review.manual_geocoding_result),
          'quality_signals' => review.quality_signals,
          'note' => review.note,
          'sim_circle_within_area' => review.sim_circle_within_area,
          'reviewed_at' => iso8601(review.reviewed_at),
          'created_at' => iso8601(review.created_at),
          'updated_at' => iso8601(review.updated_at)
        }
      end
  end

  def import_address_corrections(rows)
    rows.count do |row|
      location = find_raw_location(row.fetch('location'))
      source_location = find_raw_location(row['source_location'])

      correction = AddressCorrection.find_or_initialize_by(
        location: location,
        source: row.fetch('source'),
        method: row.fetch('method'),
        corrected_address_1: row.fetch('corrected_address_1'),
        corrected_address_2: row['corrected_address_2']
      )
      correction.source_location = source_location
      correction.confidence = row.fetch('confidence')
      correction.selected = row.fetch('selected')
      correction.evidence = row['evidence']
      correction.created_at = parse_time(row['created_at']) if row['created_at'].present?
      correction.updated_at = parse_time(row['updated_at']) if row['updated_at'].present?
      correction.save!
    end
  end

  def import_selected_geocoding_results(rows)
    rows.count do |row|
      location = find_transformed_location(row.fetch('transformed_location'))
      result = upsert_geocoding_result(location, row.fetch('result'), selected: true)
      GeocodingResult.where(transformed_location: location).where.not(id: result.id).update_all(selected: false)
      location.use_geocoding_result!(result)
      store_source_coordinates(location, result)
    end
  end

  def import_geocoding_reviews(rows)
    rows.count do |row|
      location = find_transformed_location(row.fetch('transformed_location'))
      selected_result = upsert_geocoding_result(location, row['selected_geocoding_result'])
      manual_result = upsert_geocoding_result(location, row['manual_geocoding_result'])

      review = GeocodingReview.find_or_initialize_by(
        transformed_location: location,
        signal_category: row.fetch('signal_category'),
        review_status: row.fetch('review_status'),
        reviewed_at: parse_time(row.fetch('reviewed_at'))
      )
      review.selected_geocoding_result = selected_result
      review.manual_geocoding_result = manual_result
      review.original_latitude = row['original_latitude']
      review.original_longitude = row['original_longitude']
      review.manual_latitude = row['manual_latitude']
      review.manual_longitude = row['manual_longitude']
      review.quality_signals = row.fetch('quality_signals', [])
      review.note = row['note']
      review.sim_circle_within_area = row['sim_circle_within_area']
      review.created_at = parse_time(row['created_at']) if row['created_at'].present?
      review.updated_at = parse_time(row['updated_at']) if row['updated_at'].present?
      review.save!
    end
  end

  def raw_location_identity(location)
    return unless location

    {
      'address_1' => location.address_1,
      'address_2' => location.address_2
    }
  end

  def find_raw_location(identity)
    return unless identity

    Location.find_by!(
      address_1: identity.fetch('address_1'),
      address_2: identity['address_2']
    )
  end

  def transformed_location_identity(location)
    TRANSFORMED_LOCATION_COLUMNS.index_with { |column| location.public_send(column) }
  end

  def find_transformed_location(identity)
    query = identity.slice(*TRANSFORMED_LOCATION_COLUMNS)
    TransformedLocation.find_by!(query)
  end

  def geocoding_result_payload(result)
    return unless result

    {
      'source' => result.source,
      'strategy' => result.strategy,
      'query' => result.query,
      'latitude' => result.latitude,
      'longitude' => result.longitude,
      'confidence' => result.confidence,
      'precision' => result.precision,
      'selected' => result.selected,
      'created_at' => iso8601(result.created_at),
      'updated_at' => iso8601(result.updated_at)
    }
  end

  def upsert_geocoding_result(location, payload, selected: nil)
    return unless payload

    result = GeocodingResult.find_or_initialize_by(
      transformed_location: location,
      source: payload.fetch('source'),
      strategy: payload.fetch('strategy'),
      query: payload.fetch('query')
    )
    result.latitude = payload['latitude']
    result.longitude = payload['longitude']
    result.confidence = payload['confidence']
    result.precision = payload['precision']
    result.selected = selected.nil? ? payload.fetch('selected', false) : selected
    result.created_at = parse_time(payload['created_at']) if payload['created_at'].present?
    result.updated_at = parse_time(payload['updated_at']) if payload['updated_at'].present?
    result.save!
    result
  end

  def store_source_coordinates(location, result)
    location.store_geocoder_coordinates!(result.source, result.latitude, result.longitude)
  rescue KeyError
    nil
  end

  def iso8601(value)
    value&.utc&.iso8601
  end

  def parse_time(value)
    Time.zone.parse(value)
  end
end
