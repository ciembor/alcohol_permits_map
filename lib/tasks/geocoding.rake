namespace :geocoding do
  desc 'Geocode Kraków address points with UMK MSIP/EMUiA. Optional env: LATEST_ONLY=1 LIMIT=100 THROTTLE_SECONDS=0.0'
  task krakow_msip_address_points: :environment do
    require 'geocoding/krakow_msip_address_geocoder'

    latest_only = ENV['LATEST_ONLY'] == '1'
    limit = ENV['LIMIT']&.to_i
    throttle_seconds = ENV.fetch('THROTTLE_SECONDS', '0.0').to_f

    scope = TransformedLocation.all
    scope = scope.where(id: latest_transformed_location_ids) if latest_only

    candidates = scope.select do |transformed_location|
      transformed_location.address_kind == 'street_address' &&
        transformed_location.building_number.present? &&
        !transformed_location.geocoding_results.where(
          source: Geocoding::KrakowMsipAddressGeocoder::SOURCE,
          selected: true
        ).where.not(latitude: nil, longitude: nil).exists?
    end
    candidates = candidates.first(limit) if limit

    geocoder = Geocoding::KrakowMsipAddressGeocoder.new(throttle_seconds: throttle_seconds)
    geocoded = 0
    failed = 0

    candidates.each_with_index do |transformed_location, index|
      result = geocoder.geocode(transformed_location)
      geocoded += 1 if result&.latitude.present? && result&.longitude.present?
      failed += 1 unless result&.latitude.present? && result&.longitude.present?
      puts [
        index + 1,
        candidates.size,
        transformed_location.id,
        result&.query,
        result&.latitude,
        result&.longitude,
        result&.precision,
        result&.selected? ? 'selected' : 'stored'
      ].join(' | ')
    rescue StandardError => e
      failed += 1
      warn [
        'ERROR',
        transformed_location.id,
        transformed_location.geocoding_address,
        e.class,
        e.message
      ].join(' | ')
    end

    puts({ candidates: candidates.size, geocoded: geocoded, failed: failed }.inspect)
  end

  desc 'Geocode Kraków address points with GUS Geoportal Statystyczny. Optional env: LATEST_ONLY=1 LIMIT=100 THROTTLE_SECONDS=0.0'
  task gus_address_points: :environment do
    require 'geocoding/gus_address_geocoder'

    latest_only = ENV['LATEST_ONLY'] == '1'
    limit = ENV['LIMIT']&.to_i
    throttle_seconds = ENV.fetch('THROTTLE_SECONDS', '0.0').to_f

    scope = TransformedLocation.all
    scope = scope.where(id: latest_transformed_location_ids) if latest_only

    candidates = scope.select do |transformed_location|
      transformed_location.address_kind == 'street_address' &&
        transformed_location.building_number.present? &&
        !transformed_location.geocoding_results.where(
          source: Geocoding::GusAddressGeocoder::SOURCE,
          selected: true
        ).where.not(latitude: nil, longitude: nil).exists?
    end
    candidates = candidates.first(limit) if limit

    geocoder = Geocoding::GusAddressGeocoder.new(throttle_seconds: throttle_seconds)
    geocoded = 0
    failed = 0

    candidates.each_with_index do |transformed_location, index|
      result = geocoder.geocode(transformed_location)
      geocoded += 1 if result&.latitude.present? && result&.longitude.present?
      failed += 1 unless result&.latitude.present? && result&.longitude.present?
      puts [
        index + 1,
        candidates.size,
        transformed_location.id,
        result&.query,
        result&.latitude,
        result&.longitude,
        result&.precision,
        result&.selected? ? 'selected' : 'stored'
      ].join(' | ')
    rescue StandardError => e
      failed += 1
      warn [
        'ERROR',
        transformed_location.id,
        transformed_location.geocoding_address,
        e.class,
        e.message
      ].join(' | ')
    end

    puts({ candidates: candidates.size, geocoded: geocoded, failed: failed }.inspect)
  end

  desc 'Geocode transformed locations with Nominatim. Optional env: STRATEGY=address_point LATEST_ONLY=1 LIMIT=100 THROTTLE_SECONDS=1.1'
  task nominatim: :environment do
    require 'geocoding/nominatim_geocoder'

    strategy = ENV.fetch('STRATEGY', 'address_point')
    latest_only = ENV['LATEST_ONLY'] == '1'
    limit = ENV['LIMIT']&.to_i
    throttle_seconds = ENV.fetch('THROTTLE_SECONDS', '1.1').to_f

    scope = TransformedLocation.all
    scope = scope.where(id: latest_transformed_location_ids) if latest_only

    candidates = scope.select do |transformed_location|
      transformed_location.geocoding_strategy == strategy &&
        transformed_location.geocoding_results.where(source: Geocoding::NominatimGeocoder::SOURCE, strategy: strategy).empty?
    end
    candidates = candidates.first(limit) if limit

    geocoder = Geocoding::NominatimGeocoder.new(throttle_seconds: throttle_seconds, strategy: strategy)
    geocoded = 0
    failed = 0

    candidates.each_with_index do |transformed_location, index|
      result = geocoder.geocode(transformed_location)
      geocoded += 1 if result&.latitude.present? && result&.longitude.present?
      failed += 1 unless result&.latitude.present? && result&.longitude.present?
      puts [
        index + 1,
        candidates.size,
        transformed_location.id,
        transformed_location.geocoding_address,
        result&.latitude,
        result&.longitude
      ].join(' | ')
    rescue StandardError => e
      failed += 1
      warn [
        'ERROR',
        transformed_location.id,
        transformed_location.geocoding_address,
        e.class,
        e.message
      ].join(' | ')
    end

    puts({ candidates: candidates.size, geocoded: geocoded, failed: failed }.inspect)
  end

  desc 'Geocode address_point transformed locations with Nominatim. Optional env: LATEST_ONLY=1 LIMIT=100 THROTTLE_SECONDS=1.1'
  task nominatim_address_points: :environment do
    ENV['STRATEGY'] = 'address_point'
    Rake::Task['geocoding:nominatim'].invoke
  end

  desc 'Sync transformed_locations OSM columns from stored Nominatim results. Optional env: LATEST_ONLY=1'
  task sync_osm_locations: :environment do
    require 'geocoding/osm_location_sync'

    scope = TransformedLocation.all
    scope = scope.where(id: latest_transformed_location_ids) if ENV['LATEST_ONLY'] == '1'

    result = Geocoding::OsmLocationSync.sync!(scope)
    puts result.inspect
  end

  desc 'Fill missing transformed_locations OSM columns with Nominatim without changing selected map geocoding. Optional env: LATEST_ONLY=1 LIMIT=100 THROTTLE_SECONDS=1.1'
  task osm_missing_locations: :environment do
    require 'geocoding/nominatim_geocoder'
    require 'geocoding/osm_location_sync'

    latest_only = ENV['LATEST_ONLY'] == '1'
    limit = ENV['LIMIT']&.to_i
    throttle_seconds = ENV.fetch('THROTTLE_SECONDS', '1.1').to_f

    scope = TransformedLocation
      .where('osm_latitude IS NULL OR osm_longitude IS NULL')
      .order(:id)
    scope = scope.where(id: latest_transformed_location_ids) if latest_only
    candidates = scope.to_a
    candidates = candidates.first(limit) if limit

    geocoded = 0
    failed = 0

    candidates.each_with_index do |transformed_location, index|
      result = nil
      transformed_location.geocoding_queries.each do |query|
        next if transformed_location.geocoding_results.where(
          source: Geocoding::NominatimGeocoder::SOURCE,
          strategy: query.fetch(:strategy),
          query: query.fetch(:query)
        ).where.not(latitude: nil, longitude: nil).exists?

        geocoder = Geocoding::NominatimGeocoder.new(
          throttle_seconds: throttle_seconds,
          strategy: query.fetch(:strategy),
          select_result: false
        )
        result = geocoder.geocode(transformed_location)
        break if result&.latitude.present? && result&.longitude.present?
      end

      Geocoding::OsmLocationSync.sync!(TransformedLocation.where(id: transformed_location.id))
      transformed_location.reload
      if transformed_location.osm_latitude.present? && transformed_location.osm_longitude.present?
        geocoded += 1
      else
        failed += 1
      end

      puts [
        index + 1,
        candidates.size,
        transformed_location.id,
        transformed_location.geocoding_address,
        transformed_location.osm_latitude,
        transformed_location.osm_longitude,
        transformed_location.osm_geocoding_strategy,
        transformed_location.osm_geocoding_precision
      ].join(' | ')
    rescue StandardError => e
      failed += 1
      warn [
        'ERROR',
        transformed_location.id,
        transformed_location.geocoding_address,
        e.class,
        e.message
      ].join(' | ')
    end

    puts({ candidates: candidates.size, geocoded: geocoded, failed: failed }.inspect)
  end

  desc 'Geocode cadastral parcel transformed locations with ULDK. Optional env: LATEST_ONLY=1 LIMIT=100 THROTTLE_SECONDS=0.2'
  task uldk_parcels: :environment do
    require 'geocoding/uldk_parcel_geocoder'

    latest_only = ENV['LATEST_ONLY'] == '1'
    limit = ENV['LIMIT']&.to_i
    throttle_seconds = ENV.fetch('THROTTLE_SECONDS', '0.2').to_f

    scope = TransformedLocation.all
    scope = scope.where(id: latest_transformed_location_ids) if latest_only

    candidates = scope.select do |transformed_location|
      transformed_location.geocoding_strategy == 'cadastral_parcel' &&
        !transformed_location.geocoding_results.where(
          source: Geocoding::UldkParcelGeocoder::SOURCE,
          strategy: 'cadastral_parcel',
          selected: true
        ).where.not(latitude: nil, longitude: nil).exists?
    end
    candidates = candidates.first(limit) if limit

    geocoder = Geocoding::UldkParcelGeocoder.new(throttle_seconds: throttle_seconds)
    geocoded = 0
    failed = 0

    candidates.each_with_index do |transformed_location, index|
      result = geocoder.geocode(transformed_location)
      geocoded += 1 if result&.latitude.present? && result&.longitude.present?
      failed += 1 unless result&.latitude.present? && result&.longitude.present?
      puts [
        index + 1,
        candidates.size,
        transformed_location.id,
        transformed_location.geocoding_address,
        result&.query,
        result&.latitude,
        result&.longitude,
        result&.precision
      ].join(' | ')
    rescue StandardError => e
      failed += 1
      warn [
        'ERROR',
        transformed_location.id,
        transformed_location.geocoding_address,
        e.class,
        e.message
      ].join(' | ')
    end

    puts({ candidates: candidates.size, geocoded: geocoded, failed: failed }.inspect)
  end

  desc 'Geocode transformed locations with Google Maps. Requires GOOGLE_MAPS_API_KEY. Optional env: LATEST_ONLY=1 LIMIT=100 THROTTLE_SECONDS=0.1'
  task google: :environment do
    run_google_geocoding
  end

  def run_google_geocoding
    require 'geocoding/google_maps_geocoder'

    latest_only = ENV['LATEST_ONLY'] == '1'
    limit = ENV['LIMIT']&.to_i
    throttle_seconds = ENV.fetch('THROTTLE_SECONDS', '0.1').to_f

    scope = TransformedLocation
      .left_joins(:geocoding_results)
      .distinct
    scope = scope.where(id: latest_transformed_location_ids) if latest_only

    candidates = scope.select do |transformed_location|
      google_geocoding_candidate?(transformed_location)
    end
    candidates = candidates.first(limit) if limit

    geocoder = Geocoding::GoogleMapsGeocoder.new(throttle_seconds: throttle_seconds)
    geocoded = 0
    selected = 0
    failed = 0

    candidates.each_with_index do |transformed_location, index|
      before_selected_id = selected_geocoding_result(transformed_location)&.id
      result = geocoder.geocode(transformed_location)
      after_selected_id = selected_geocoding_result(transformed_location.reload)&.id
      geocoded += 1 if result&.latitude.present? && result&.longitude.present?
      selected += 1 if result&.id.present? && after_selected_id == result.id && before_selected_id != after_selected_id
      failed += 1 unless result&.latitude.present? && result&.longitude.present?

      puts [
        index + 1,
        candidates.size,
        transformed_location.id,
        result&.query,
        result&.latitude,
        result&.longitude,
        result&.precision,
        after_selected_id == result&.id ? 'selected' : 'stored'
      ].join(' | ')
    rescue StandardError => e
      failed += 1
      warn [
        'ERROR',
        transformed_location.id,
        transformed_location.geocoding_address,
        e.class,
        e.message
      ].join(' | ')
    end

    puts({ candidates: candidates.size, geocoded: geocoded, selected: selected, failed: failed }.inspect)
  end

  def latest_transformed_location_ids
    latest = AlcoholLicense.maximum(:reported_at)
    location_ids = AlcoholLicense.where(reported_at: latest).distinct.pluck(:location_id)
    Location.where(id: location_ids).distinct.pluck(:transformed_location_id).compact
  end

  def selected_geocoding_result(transformed_location)
    transformed_location.geocoding_results.where(selected: true).order(id: :desc).first
  end

  def google_geocoding_candidate?(transformed_location)
    transformed_location.geocoding_address.to_s.strip.present?
  end
end
