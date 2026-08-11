require_dependency 'sim/locator'
require 'digest'

class GeocodingReviewCandidateFinder
  RANDOM_SAMPLE_SIZE = 357
  RANDOM_SAMPLE_SEED = 'geocoding-quality-sample-v1'
  MSIP_REVIEW_DISTANCE_THRESHOLD_METERS = 25
  RANDOM_SAMPLE_CATEGORIES = %w[random_sample random_sample_msip_regression].freeze
  RANDOM_SAMPLE_REVIEW_FOLLOW_UP_KEYS = %w[
    Meiselsa|20|1||||street_address
    Miodowa|32|3||||street_address
  ].freeze
  RANDOM_SAMPLE_REVIEW_FOLLOW_UP_REVIEWED_AFTER = Time.utc(2026, 8, 11, 13, 33, 33)

  CATEGORY_DEFINITIONS = [
    ['critical_missing', 'Braki krytyczne', 'priority'],
    ['google_osm_distance_large', 'Duża odległość', 'priority'],
    ['random_sample', 'Próba losowa 357', 'control']
  ].freeze

  DISTANCE_CATEGORIES = {
    'google_osm_distance_large' => [500, nil],
    'google_osm_distance_1000' => [1000, nil],
    'google_osm_distance_500' => [500, 1000],
    'google_osm_distance_250' => [250, 500],
    'google_osm_distance_100' => [100, 250],
    'google_osm_distance_50' => [50, 100]
  }.freeze
  REVIEW_CATEGORY_ALIASES = {
    'random_sample' => %w[
      random_sample
      random_sample_msip_regression
    ],
    'google_osm_distance_large' => %w[
      google_osm_distance_large
      google_osm_distance_1000
      google_osm_distance_500
    ]
  }.freeze

  LOW_PRECISION_GOOGLE_PREFIXES = %w[APPROXIMATE GEOMETRIC_CENTER RANGE_INTERPOLATED].freeze
  LOW_PRECISION_OSM_SUFFIXES = %w[road neighbourhood quarter junction].freeze
  WEAK_STRATEGIES = %w[street_fallback teryt_named_object described_place].freeze
  UNUSUAL_ADDRESS_KINDS = %w[parcel pavilion landmark near_building compound_address].freeze
  KEY_AREAS = ['Kazimierz', 'Stare Miasto', 'Stare Podgórze', 'Piasek', 'Kleparz'].freeze
  GEOCODER_SOURCE_LABELS = {
    'google' => 'Google',
    'nominatim' => 'OSM/Nominatim',
    'gus' => 'GUS',
    'krakow_msip' => 'MSIP',
    'uldk' => 'ULDK'
  }.freeze
  GEOCODER_SOURCE_ORDER = GEOCODER_SOURCE_LABELS.keys.each_with_index.to_h.freeze

  def initialize(sim_locator: Sim::Locator.new)
    @sim_locator = sim_locator
    @selected_results = nil
  end

  def categories
    CATEGORY_DEFINITIONS.map do |key, label, group|
      candidates = matching_locations(key)
      candidate_ids = candidates.map(&:id).to_set
      reviewed_ids = reviewed_location_ids_for(key)
      corrected_ids = reviewed_location_ids_for(key, statuses: ['corrected'])
      unresolved_ids = unresolved_location_ids_for(key)

      {
        key: key,
        label: label,
        group: group,
        total: candidates.size,
        reviewed: (reviewed_ids & candidate_ids).size,
        corrected: (corrected_ids & candidate_ids).size,
        unresolved: (unresolved_ids & candidate_ids).size
      }
    end
  end

  def next_candidate(category:)
    category = category.presence || CATEGORY_DEFINITIONS.first.first
    candidates = matching_locations(category)
    candidates = without_reviewed(candidates, category)
    candidate = sort_locations(candidates, category).first

    candidate && serialize_location(candidate, category)
  end

  def serialize_location(location, active_category)
    selected = selected_results[location.id]
    google = google_result(location)
    osm = osm_candidate(location)
    sim = locate(location.latitude, location.longtitude)
    distance = google_osm_distance(location)

    current = coordinate_payload('current', 'Wybrane', location.latitude, location.longtitude, selected&.source, selected&.strategy, selected&.precision) ||
              google && coordinate_payload('google', 'Google', google.latitude, google.longitude, google.source, google.strategy, google.precision) ||
              osm ||
              coordinate_payload('fallback', 'Kraków', 50.06143, 19.93658, nil, nil, 'fallback/map_center')

    {
      id: location.id,
      active_category: active_category,
      signal_categories: [active_category],
      signal_reasons: [],
      address: display_address(location),
      business_names: business_names_for_location(location),
      normalized: {
        address_1: location.address_1,
        building_number: location.building_number,
        unit_number: location.unit_number,
        parcel_number: location.parcel_number,
        parcel_region: location.parcel_region,
        parcel_cadastral_unit: location.parcel_cadastral_unit,
        address_kind: location.address_kind,
        address_relation: location.address_relation,
        raw_address_2: location.raw_address_2
      },
      selected: serialize_result(selected),
      current: current,
      google: google && coordinate_payload('google', 'Google', google.latitude, google.longitude, google.source, google.strategy, google.precision),
      osm: osm,
      geocoder_points: geocoder_points(location),
      candidates: candidates_for(location),
      google_osm_distance_m: distance && distance.round(1),
      sim: sim,
      reviews: reviews_for(location)
    }
  end

  private

  attr_reader :sim_locator

  def latest_location_scope
    @latest_location_scope ||= TransformedLocation
      .joins(locations: :alcohol_licenses)
      .distinct
  end

  def latest_locations
    @latest_locations ||= latest_location_scope.includes(:locations).to_a
  end

  def latest_location_ids
    @latest_location_ids ||= latest_locations.map(&:id)
  end

  def selected_results
    @selected_results ||= GeocodingResult
      .where(transformed_location_id: review_location_ids, selected: true)
      .index_by(&:transformed_location_id)
  end

  def matching_locations(category)
    return random_sample_locations_for(category) if random_sample_category?(category)

    latest_locations.select { |location| matches_category?(location, category) }
  end

  def matches_category?(location, category)
    case category
    when 'critical_missing'
      critical_missing?(location)
    when 'location_uncertain'
      location_uncertainty_reasons(location).any?
    when *DISTANCE_CATEGORIES.keys
      google_osm_comparable?(location) && distance_in_category?(google_osm_distance(location), category)
    when 'low_precision'
      low_precision?(location)
    when 'weak_strategy'
      weak_strategy?(location)
    when 'unusual_address'
      UNUSUAL_ADDRESS_KINDS.include?(location.address_kind.to_s)
    when 'corrections'
      selected_address_correction?(location)
    when 'grouping'
      grouping_signals(location).any?
    when 'key_areas'
      KEY_AREAS.include?(locate(location.latitude, location.longtitude)&.fetch(:name))
    else
      false
    end
  end

  def critical_missing?(location)
    selected_results[location.id].blank? ||
      location.latitude.blank? ||
      location.longtitude.blank? ||
      locate(location.latitude, location.longtitude).blank?
  end

  def sort_locations(locations, category)
    locations.sort_by do |location|
      [
        review_queue_sort_value(location, category),
        review_queue_time_sort_value(location, category),
        category_sort_value(location, category),
        -license_count_for_location(location),
        location.id
      ]
    end
  end

  def reviewed_sort_value(location, category)
    reviewed_location_ids_for(category).include?(location.id) ? 1 : 0
  end

  def review_queue_sort_value(location, category)
    return random_sample_review_queue_sort_value(location, category) if random_sample_category?(category)

    reviewed_sort_value(location, category)
  end

  def random_sample_review_queue_sort_value(location, category)
    review = latest_random_sample_reviews_by_location_id(category)[location.id]
    return 0 unless review
    return 1 if random_sample_follow_up_required?(location, review)
    return 2 if review.review_status == 'hard_to_tell'

    3
  end

  def review_queue_time_sort_value(location, category)
    return 0 unless random_sample_category?(category)

    review = latest_random_sample_reviews_by_location_id(category)[location.id]
    return 0 unless review&.review_status == 'hard_to_tell'

    review.reviewed_at.to_f
  end

  def category_sort_value(location, category)
    case category
    when *DISTANCE_CATEGORIES.keys
      google_osm_comparable?(location) ? -google_osm_distance(location).to_f : 0
    when 'critical_missing'
      critical_missing_rank(location)
    when 'low_precision'
      low_precision_rank(location)
    when 'weak_strategy'
      weak_strategy_rank(location)
    when 'unusual_address'
      UNUSUAL_ADDRESS_KINDS.index(location.address_kind.to_s) || 99
    when 'corrections'
      correction_sort_rank(location)
    when 'grouping'
      -grouping_signals(location).size
    when 'key_areas'
      location_uncertainty_reasons(location).any? ? 0 : 1
    when *RANDOM_SAMPLE_CATEGORIES
      random_sample_sort_value(location, category)
    else
      0
    end
  end

  def review_location_ids
    @review_location_ids ||= (latest_location_ids + random_sample_location_ids_for('random_sample') + random_sample_location_ids_for('random_sample_msip_regression')).uniq
  end

  def random_sample_location_ids_for(category)
    random_sample_locations_for(category).map(&:id)
  end

  def random_sample_locations_for(category)
    @random_sample_locations_by_category ||= {}
    @random_sample_locations_by_category[category] ||= begin
      universe = random_sample_universe_for(category)
      required = random_sample_review_required_locations_for(category, universe)
      required_keys = required.map { |location| normalized_location_key(location) }.to_set
      selected = reviewed_random_sample_locations_for(category, universe)
        .reject { |location| required_keys.include?(normalized_location_key(location)) }
      selected_keys = (required + selected).map { |location| normalized_location_key(location) }.to_set
      top_up = universe
        .reject { |location| selected_keys.include?(normalized_location_key(location)) }
        .sort_by { |location| random_sample_sort_value(location, category) }

      (required + selected + top_up).first(RANDOM_SAMPLE_SIZE)
    end
  end

  def random_sample_universe_for(category)
    return msip_regression_locations if category == 'random_sample_msip_regression'

    all_normalized_locations
  end

  def reviewed_random_sample_locations_for(category, universe)
    latest_random_sample_reviews_for_universe(category, universe).values
      .map(&:transformed_location)
      .sort_by { |location| random_sample_sort_value(location, category) }
  end

  def random_sample_review_required_locations_for(category, universe)
    latest_random_sample_reviews_for_universe(category, universe).values
      .select { |review| random_sample_review_required?(review) }
      .map(&:transformed_location)
      .sort_by { |location| random_sample_sort_value(location, category) }
  end

  def latest_random_sample_reviews_for_universe(category, universe)
    return {} unless category == 'random_sample'

    locations_by_id = universe.index_by(&:id)

    GeocodingReview
      .includes(:transformed_location)
      .where(signal_category: 'random_sample')
      .order(:transformed_location_id, reviewed_at: :desc, id: :desc)
      .to_a
      .each_with_object({}) do |review, memo|
        location = locations_by_id[review.transformed_location_id]
        next unless location

        memo[review.transformed_location_id] ||= review
      end
  end

  def msip_regression_locations
    reviewed_random_sample_locations_by_id.values.select do |review|
      location = review.transformed_location
      reviewed_result = review.selected_geocoding_result
      next false unless location.selected_geocoding_source == 'krakow_msip'
      next false if reviewed_result.blank? || reviewed_result.source == 'krakow_msip'
      next false unless location.krakow_msip_latitude && location.krakow_msip_longitude
      next false unless reviewed_result.latitude && reviewed_result.longitude

      distance_m(
        location.krakow_msip_latitude,
        location.krakow_msip_longitude,
        reviewed_result.latitude,
        reviewed_result.longitude
      ) > MSIP_REVIEW_DISTANCE_THRESHOLD_METERS
    end.map(&:transformed_location)
  end

  def reviewed_random_sample_locations_by_id
    @reviewed_random_sample_locations_by_id ||= GeocodingReview
      .includes(:selected_geocoding_result, :transformed_location)
      .where(signal_category: 'random_sample')
      .where.not(review_status: 'hard_to_tell')
      .order(:transformed_location_id, reviewed_at: :desc, id: :desc)
      .to_a
      .each_with_object({}) do |review, memo|
        memo[review.transformed_location_id] ||= review
      end
  end

  def all_normalized_locations
    @all_normalized_locations ||= TransformedLocation
      .joins(:locations)
      .includes(:locations)
      .distinct
      .to_a
      .uniq { |location| normalized_location_key(location) }
  end

  def normalized_location_key(location)
    [
      location.address_1,
      location.building_number,
      location.unit_number,
      location.parcel_number,
      location.parcel_region,
      location.parcel_cadastral_unit,
      location.address_kind
    ].map(&:to_s).join('|')
  end

  def random_sample_sort_value(location, category)
    Digest::SHA256.hexdigest("#{random_sample_seed_for(category)}:#{normalized_location_key(location)}:#{location.id}").to_i(16)
  end

  def random_sample_seed_for(category)
    category == 'random_sample_msip_regression' ? "#{RANDOM_SAMPLE_SEED}:msip-regression" : RANDOM_SAMPLE_SEED
  end

  def critical_missing_rank(location)
    return 0 if location.latitude.blank? || location.longtitude.blank?
    return 1 if selected_results[location.id].blank?
    return 2 if locate(location.latitude, location.longtitude).blank?

    99
  end

  def without_reviewed(locations, category)
    reviewed_ids = reviewed_location_ids_for(category)

    locations.reject { |location| reviewed_ids.include?(location.id) }
  end

  def reviewed_location_ids_for(category, statuses: nil)
    @reviewed_location_ids_by_category ||= {}
    cache_key = [category, Array(statuses).sort]

    if random_sample_category?(category) && statuses.blank?
      return random_sample_reviewed_location_ids(category)
    end

    @reviewed_location_ids_by_category[cache_key] ||= GeocodingReview
      .where(transformed_location_id: review_candidate_ids_for(category), signal_category: review_signal_categories_for(category))
      .then { |scope| statuses ? scope.where(review_status: statuses) : scope }
      .pluck(:transformed_location_id)
      .to_set
  end

  def review_signal_categories_for(category)
    REVIEW_CATEGORY_ALIASES.fetch(category, [category])
  end

  def review_candidate_ids_for(category)
    random_sample_category?(category) ? random_sample_location_ids_for(category) : latest_location_ids
  end

  def unresolved_location_ids_for(category)
    return unreviewed_random_sample_location_ids(category) if random_sample_category?(category)

    reviewed_location_ids_for(category, statuses: ['unresolved'])
  end

  def random_sample_reviewed_location_ids(category)
    latest_random_sample_reviews_by_location_id(category).keys.to_set - random_sample_review_required_location_ids(category)
  end

  def random_sample_review_required_location_ids(category)
    return Set.new unless category == 'random_sample'

    latest_random_sample_reviews_by_location_id(category).each_with_object(Set.new) do |(location_id, review), ids|
      ids << location_id if random_sample_review_required?(review)
    end
  end

  def random_sample_review_required?(review)
    location = review.transformed_location
    return false unless location

    review.review_status == 'hard_to_tell' || random_sample_follow_up_required?(location, review)
  end

  def random_sample_follow_up_required?(location, review)
    return false unless RANDOM_SAMPLE_REVIEW_FOLLOW_UP_KEYS.include?(normalized_location_key(location))

    review.reviewed_at <= RANDOM_SAMPLE_REVIEW_FOLLOW_UP_REVIEWED_AFTER
  end

  def unreviewed_random_sample_location_ids(category)
    random_sample_location_ids_for(category).to_set - random_sample_reviewed_location_ids(category)
  end

  def latest_random_sample_reviews_by_location_id(category)
    @latest_random_sample_reviews_by_location_id ||= {}
    @latest_random_sample_reviews_by_location_id[category] ||= GeocodingReview
      .includes(:transformed_location)
      .where(transformed_location_id: random_sample_location_ids_for(category), signal_category: review_signal_categories_for(category))
      .order(:transformed_location_id, reviewed_at: :desc, id: :desc)
      .to_a
      .each_with_object({}) do |review, memo|
        memo[review.transformed_location_id] ||= review
      end
  end

  def random_sample_category?(category)
    RANDOM_SAMPLE_CATEGORIES.include?(category)
  end

  def low_precision?(location)
    result = selected_results[location.id]
    precision = result&.precision.to_s
    return true if LOW_PRECISION_GOOGLE_PREFIXES.any? { |prefix| precision.start_with?(prefix) }
    return true if LOW_PRECISION_OSM_SUFFIXES.any? { |suffix| precision.end_with?("/#{suffix}") }
    return true if precision.start_with?('derived/')

    precision.blank?
  end

  def low_precision_rank(location)
    precision = selected_results[location.id]&.precision.to_s
    return 0 if precision.start_with?('APPROXIMATE')
    return 1 if precision.end_with?('/neighbourhood') || precision.end_with?('/quarter')
    return 2 if precision.end_with?('/road') || precision.end_with?('/junction')
    return 3 if precision.start_with?('GEOMETRIC_CENTER')
    return 4 if precision.start_with?('RANGE_INTERPOLATED')
    return 5 if precision.start_with?('derived/')

    99
  end

  def weak_strategy?(location)
    result = selected_results[location.id]
    return true if WEAK_STRATEGIES.include?(result&.strategy.to_s)
    return true if result&.strategy == 'cadastral_parcel' && !result.precision.to_s.start_with?('parcel/')
    return true if location.address_kind == 'street_address' && result&.source.present? && result.source != 'google'

    false
  end

  def weak_strategy_rank(location)
    result = selected_results[location.id]
    return 0 if result&.strategy == 'street_fallback'
    return 1 if result&.strategy == 'teryt_named_object'
    return 2 if result&.strategy == 'cadastral_parcel' && !result.precision.to_s.start_with?('parcel/')
    return 3 if result&.strategy == 'described_place'
    return 4 if location.address_kind == 'street_address' && result&.source != 'google'

    99
  end

  def selected_address_correction?(location)
    selected_corrections_by_location_id.key?(location.id)
  end

  def correction_sort_rank(location)
    corrections = selected_corrections_by_location_id.fetch(location.id, [])

    return 0 if corrections.any? { |correction| correction.source == 'internal_history' }
    return 1 if corrections.any?

    99
  end

  def selected_corrections_by_location_id
    @selected_corrections_by_location_id ||= AddressCorrection
      .joins(:location)
      .where(locations: { transformed_location_id: latest_location_ids }, selected: true)
      .select('address_corrections.*', 'locations.transformed_location_id AS review_transformed_location_id')
      .to_a
      .group_by { |correction| correction.read_attribute(:review_transformed_location_id) }
  end

  def grouping_signals(location)
    licenses = licenses_for_location(location)
    groups = groups_for_licenses(licenses)
    signals = []

    groups.each do |group|
      signals << 'punkt obejmuje więcej niż jeden business_id' if group.fetch(:business_id_count) > 1
      signals << 'business_similarity_floor < 1' if group.fetch(:similarity_floor).to_f < 1
      signals << 'więcej niż 6 zezwoleń w punkcie' if group.fetch(:license_count) > 6
      signals << 'punkt mieszany detal/gastronomia' if group.fetch(:business_categories).size > 1
    end

    signals << 'więcej niż jedna grupa punktów pod tymi samymi współrzędnymi' if groups.size > 1
    signals.uniq
  end

  def location_uncertainty_reasons(location)
    result = selected_results[location.id]

    Geocoding::LocationUncertainty.reasons(
      geocoding_source: result&.source,
      geocoding_strategy: result&.strategy,
      geocoding_precision: result&.precision,
      address_kind: location.address_kind
    )
  end

  def quality_signals(location)
    categories = CATEGORY_DEFINITIONS.map(&:first).select { |category| matches_category?(location, category) }
    reasons = location_uncertainty_reasons(location) + grouping_signals(location)
    distance = google_osm_distance(location)
    reasons << "Google-OSM: #{distance.round(1)} m" if distance

    {
      categories: categories,
      reasons: reasons.uniq
    }
  end

  def google_osm_distance(location)
    google = google_result(location)
    return unless google&.latitude && google&.longitude && location.osm_latitude && location.osm_longitude

    distance_m(google.latitude, google.longitude, location.osm_latitude, location.osm_longitude)
  end

  def distance_in_category?(distance, category)
    min, max = DISTANCE_CATEGORIES.fetch(category)
    distance = distance.to_f

    distance > min && (max.nil? || distance <= max)
  end

  def google_osm_comparable?(location)
    google = google_result(location)
    return false unless google&.latitude && google&.longitude && location.osm_latitude && location.osm_longitude

    locate(google.latitude, google.longitude).present? &&
      locate(location.osm_latitude, location.osm_longitude).present?
  end

  def google_result(location)
    google_results_by_location_id[location.id]
  end

  def google_results_by_location_id
    @google_results_by_location_id ||= GeocodingResult
      .where(transformed_location_id: review_location_ids, source: 'google')
      .where.not(latitude: nil, longitude: nil)
      .order(selected: :desc, id: :desc)
      .to_a
      .each_with_object({}) do |result, memo|
        memo[result.transformed_location_id] ||= result
      end
  end

  def geocoder_points(location)
    result_points = geocoder_results_by_location_id.fetch(location.id, []).sort_by { |result| GEOCODER_SOURCE_ORDER.fetch(result.source, 999) }.map do |result|
      serialize_result(result).merge(
        kind: result.source,
        label: GEOCODER_SOURCE_LABELS.fetch(result.source, result.source.upcase)
      )
    end

    (result_points + [osm_candidate(location)]).compact.uniq do |point|
      [
        point[:source] || point[:kind],
        point[:lat].to_f.round(7),
        point[:lng].to_f.round(7)
      ]
    end
  end

  def geocoder_results_by_location_id
    @geocoder_results_by_location_id ||= GeocodingResult
      .where(transformed_location_id: review_location_ids, source: GEOCODER_SOURCE_LABELS.keys)
      .where.not(latitude: nil, longitude: nil)
      .order(selected: :desc, id: :desc)
      .to_a
      .uniq { |result| [result.transformed_location_id, result.source] }
      .group_by(&:transformed_location_id)
  end

  def osm_candidate(location)
    return unless location.osm_latitude && location.osm_longitude

    coordinate_payload(
      'osm',
      'OSM',
      location.osm_latitude,
      location.osm_longitude,
      'nominatim',
      location.osm_geocoding_strategy,
      location.osm_geocoding_precision,
      location.osm_geocoding_query
    )
  end

  def candidates_for(location)
    google = google_result(location)

    ([serialize_result(selected_results[location.id])&.merge(kind: 'selected', label: 'Wybrane')] +
      [google && serialize_result(google)&.merge(kind: 'google', label: 'Google')] +
      [osm_candidate(location)] +
      parcel_candidates(location) +
      manual_candidates(location)).compact.uniq { |candidate| [candidate[:kind], candidate[:lat], candidate[:lng]] }
  end

  def parcel_candidates(location)
    parcel_candidates_by_location_id.fetch(location.id, [])
  end

  def parcel_candidates_by_location_id
    @parcel_candidates_by_location_id ||= GeocodingResult
      .where(transformed_location_id: review_location_ids, source: 'uldk', selected: true)
      .where.not(latitude: nil, longitude: nil)
      .order(selected: :desc, id: :desc)
      .map { |result| [result.transformed_location_id, serialize_result(result).merge(kind: result.source, label: result.source.upcase)] }
      .group_by(&:first)
      .transform_values { |values| values.map(&:last) }
  end

  def manual_candidates(location)
    manual_candidates_by_location_id.fetch(location.id, [])
  end

  def manual_candidates_by_location_id
    @manual_candidates_by_location_id ||= GeocodingResult
      .where(transformed_location_id: review_location_ids, source: 'manual_review', selected: true)
      .where.not(latitude: nil, longitude: nil)
      .order(selected: :desc, id: :desc)
      .map { |result| [result.transformed_location_id, serialize_result(result).merge(kind: 'manual_review', label: 'Ręczne')] }
      .group_by(&:first)
      .transform_values { |values| values.map(&:last) }
  end

  def serialize_result(result)
    return unless result

    {
      id: result.id,
      source: result.source,
      strategy: result.strategy,
      query: result.query,
      lat: result.latitude,
      lng: result.longitude,
      confidence: result.confidence,
      precision: result.precision,
      selected: result.selected?
    }
  end

  def coordinate_payload(kind, label, latitude, longitude, source = nil, strategy = nil, precision = nil, query = nil)
    return unless latitude && longitude

    {
      kind: kind,
      label: label,
      lat: latitude,
      lng: longitude,
      source: source,
      strategy: strategy,
      precision: precision,
      query: query
    }
  end

  def display_address(location)
    [
      location.address_1,
      location.building_number,
      location.unit_number.presence && "lok. #{location.unit_number}",
      location.parcel_number.presence && "dz. #{location.parcel_number}"
    ].compact.join(' ')
  end

  def licenses_for_location(location)
    licenses_by_location_id.fetch(location.id, [])
  end

  def license_count_for_location(location)
    license_counts_by_location_id.fetch(location.id, 0)
  end

  def license_counts_by_location_id
    @license_counts_by_location_id ||= AlcoholLicense
      .joins(location: :transformed_location)
      .where(transformed_locations: { id: latest_location_ids })
      .group('locations.transformed_location_id')
      .count
  end

  def licenses_by_location_id
    @licenses_by_location_id ||= AlcoholLicense
      .joins(:business, :business_category, :license_category, location: :transformed_location)
      .where(reported_at: latest_report_at, transformed_locations: { id: latest_location_ids })
      .includes(:business, :business_category, :license_category)
      .select('alcohol_licenses.*', 'locations.transformed_location_id AS review_transformed_location_id')
      .to_a
      .group_by { |license| license.read_attribute(:review_transformed_location_id) }
  end

  def latest_report_at
    @latest_report_at ||= AlcoholLicense.maximum(:reported_at)
  end

  def business_names_for_location(location)
    AlcoholLicense
      .joins(:business, location: :transformed_location)
      .where(transformed_locations: { id: location.id })
      .includes(:business)
      .to_a
      .map { |license| license.business.name }
      .uniq
      .sort
      .first(8)
  end

  def groups_for_licenses(licenses)
    licenses.group_by(&:license_point_group_id).map do |group_id, group_licenses|
      group = license_point_groups_by_id[group_id]
      business_categories = group_licenses.map { |license| license.business_category.name }.uniq.sort

      {
        id: group_id,
        display_business_name: group&.display_business_name || group_licenses.first.business.name,
        business_names: group&.business_names || group_licenses.map { |license| license.business.name }.uniq.sort,
        business_id_count: (group&.business_ids || group_licenses.map(&:business_id)).uniq.size,
        business_categories: business_categories,
        license_count: group_licenses.size,
        similarity_floor: group&.similarity_floor
      }
    end
  end

  def license_point_groups_by_id
    @license_point_groups_by_id ||= LicensePointGroup
      .where(id: licenses_by_location_id.values.flatten.map(&:license_point_group_id).compact.uniq)
      .index_by(&:id)
  end

  def reviews_for(location)
    GeocodingReview
      .where(transformed_location_id: location.id)
      .order(reviewed_at: :desc, id: :desc)
      .limit(10)
      .map do |review|
        {
          signal_category: review.signal_category,
          review_status: review.review_status,
          reviewed_at: review.reviewed_at,
          manual_latitude: review.manual_latitude,
          manual_longitude: review.manual_longitude,
          note: review.note
        }
      end
  end

  def locate(latitude, longitude)
    return unless latitude && longitude

    @sim_locations_by_coordinates ||= {}
    @sim_locations_by_coordinates[[latitude, longitude]] ||= sim_locator.locate(latitude, longitude)
  end

  def distance_m(lat1, lon1, lat2, lon2)
    radius = 6_371_000.0
    radians = Math::PI / 180
    dlat = (lat2 - lat1) * radians
    dlon = (lon2 - lon1) * radians
    a = Math.sin(dlat / 2)**2 +
        Math.cos(lat1 * radians) * Math.cos(lat2 * radians) * Math.sin(dlon / 2)**2

    2 * radius * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
  end
end
