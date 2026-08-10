require 'test_helper'

class GeocodingReviewCandidateFinderTest < ActiveSupport::TestCase
  def create_license_for(transformed_location, business_name:)
    business_category = BusinessCategory.find_or_create_by!(name: 'detal')
    license_category = LicenseCategory.find_or_create_by!(name: 'A')
    business = Business.create!(name: business_name)
    location = Location.create!(
      address_1: transformed_location.address_1,
      address_2: transformed_location.building_number,
      transformed_location: transformed_location
    )

    AlcoholLicense.create!(
      business: business,
      business_category: business_category,
      license_category: license_category,
      location: location,
      reported_at: Time.utc(2026, 2, 6, 8, 43, 9),
      expires_at: Time.utc(2027, 1, 1)
    )
  end

  test 'combines large google osm distance categories and hides msip regression from tool categories' do
    far_location = TransformedLocation.create!(
      address_1: 'Długa',
      building_number: '20',
      address_kind: 'street_address',
      latitude: 50.0641,
      longtitude: 19.9391,
      osm_latitude: 50.0641,
      osm_longitude: 19.9591
    )
    mid_location = TransformedLocation.create!(
      address_1: 'Długa',
      building_number: '21',
      address_kind: 'street_address',
      latitude: 50.0641,
      longtitude: 19.9391,
      osm_latitude: 50.0641,
      osm_longitude: 19.9491
    )
    create_license_for(far_location, business_name: 'FAR DISTANCE TEST')
    create_license_for(mid_location, business_name: 'MID DISTANCE TEST')

    far_google = GeocodingResult.create!(
      transformed_location: far_location,
      source: 'google',
      strategy: 'address_point',
      query: 'Długa 20 Kraków',
      latitude: 50.0641,
      longitude: 19.9391
    )
    mid_google = GeocodingResult.create!(
      transformed_location: mid_location,
      source: 'google',
      strategy: 'address_point',
      query: 'Długa 21 Kraków',
      latitude: 50.0641,
      longitude: 19.9391
    )
    GeocodingReview.create!(
      transformed_location: far_location,
      signal_category: 'google_osm_distance_1000',
      review_status: 'corrected',
      selected_geocoding_result: far_google,
      reviewed_at: Time.current
    )
    GeocodingReview.create!(
      transformed_location: mid_location,
      signal_category: 'google_osm_distance_500',
      review_status: 'unresolved',
      selected_geocoding_result: mid_google,
      reviewed_at: Time.current
    )

    categories = GeocodingReviewCandidateFinder.new.categories
    keys = categories.map { |category| category.fetch(:key) }
    large_distance = categories.find { |category| category.fetch(:key) == 'google_osm_distance_large' }

    assert_includes keys, 'google_osm_distance_large'
    assert_not_includes keys, 'google_osm_distance_1000'
    assert_not_includes keys, 'google_osm_distance_500'
    assert_not_includes keys, 'random_sample_msip_regression'
    assert_equal 'Duża odległość', large_distance.fetch(:label)
    assert_operator large_distance.fetch(:total), :>=, 2
    assert_equal 2, large_distance.fetch(:reviewed)
    assert_equal 1, large_distance.fetch(:corrected)
    assert_equal 1, large_distance.fetch(:unresolved)
  end

  test 'serializes all available geocoder points for distance comparison' do
    business_category = BusinessCategory.create!(name: 'detal')
    license_category = LicenseCategory.create!(name: 'A')
    business = Business.create!(name: 'TEST')
    transformed_location = TransformedLocation.create!(
      address_1: 'Długa',
      building_number: '10',
      address_kind: 'street_address',
      latitude: 50.0641,
      longtitude: 19.9391
    )
    location = Location.create!(
      address_1: 'DŁUGA',
      address_2: '10',
      transformed_location: transformed_location
    )
    AlcoholLicense.create!(
      business: business,
      business_category: business_category,
      license_category: license_category,
      location: location,
      reported_at: Time.utc(2026, 2, 6, 8, 43, 9),
      expires_at: Time.utc(2027, 1, 1)
    )

    GeocodingResult.create!(
      transformed_location: transformed_location,
      source: 'google',
      strategy: 'address_point',
      query: 'Długa 10 Kraków',
      latitude: 50.0641,
      longitude: 19.9391
    )
    GeocodingResult.create!(
      transformed_location: transformed_location,
      source: 'gus',
      strategy: 'address_point',
      query: 'Długa 10 Kraków',
      latitude: 50.0642,
      longitude: 19.9392
    )
    GeocodingResult.create!(
      transformed_location: transformed_location,
      source: 'krakow_msip',
      strategy: 'address_point',
      query: 'Długa 10 Kraków',
      latitude: 50.0643,
      longitude: 19.9393
    )

    serialized = GeocodingReviewCandidateFinder
      .new
      .send(:serialize_location, transformed_location, 'random_sample')

    points = serialized.fetch(:geocoder_points)
    assert_equal %w[google gus krakow_msip], points.map { |point| point.fetch(:source) }
    assert_equal ['Google', 'GUS', 'MSIP'], points.map { |point| point.fetch(:label) }
  end

  test 'serializes osm column point for distance comparison without stored nominatim result' do
    transformed_location = TransformedLocation.create!(
      address_1: 'Długa',
      building_number: '10',
      address_kind: 'street_address',
      latitude: 50.0641,
      longtitude: 19.9391,
      osm_latitude: 50.0642,
      osm_longitude: 19.9392,
      osm_geocoding_strategy: 'address_point',
      osm_geocoding_precision: 'house/place'
    )
    create_license_for(transformed_location, business_name: 'OSM COLUMN TEST')
    GeocodingResult.create!(
      transformed_location: transformed_location,
      source: 'krakow_msip',
      strategy: 'address_point',
      query: 'Długa 10 Kraków',
      latitude: 50.0641,
      longitude: 19.9391,
      selected: true
    )

    serialized = GeocodingReviewCandidateFinder
      .new
      .send(:serialize_location, transformed_location, 'critical_missing')

    points = serialized.fetch(:geocoder_points)
    assert_includes points.map { |point| point.fetch(:label) }, 'MSIP'
    assert_includes points.map { |point| point.fetch(:label) }, 'OSM'
  end

  test 'msip regression sample uses only old random sample reviews moved by MSIP over threshold' do
    moved_location = TransformedLocation.create!(
      address_1: 'Długa',
      building_number: '11',
      address_kind: 'street_address',
      latitude: 50.0643,
      longtitude: 19.9393,
      krakow_msip_latitude: 50.0643,
      krakow_msip_longitude: 19.9393,
      selected_geocoding_source: 'krakow_msip'
    )
    close_location = TransformedLocation.create!(
      address_1: 'Długa',
      building_number: '12',
      address_kind: 'street_address',
      latitude: 50.0644,
      longtitude: 19.9394,
      krakow_msip_latitude: 50.0644,
      krakow_msip_longitude: 19.9394,
      selected_geocoding_source: 'krakow_msip'
    )
    google_location = TransformedLocation.create!(
      address_1: 'Długa',
      building_number: '13',
      address_kind: 'street_address',
      latitude: 50.0645,
      longtitude: 19.9395,
      krakow_msip_latitude: 50.0645,
      krakow_msip_longitude: 19.9395,
      selected_geocoding_source: 'google'
    )
    create_license_for(moved_location, business_name: 'MSIP MOVED TEST')
    create_license_for(close_location, business_name: 'MSIP CLOSE TEST')
    create_license_for(google_location, business_name: 'GOOGLE TEST')

    moved_reviewed_result = GeocodingResult.create!(
      transformed_location: moved_location,
      source: 'google',
      strategy: 'address_point',
      query: 'Długa 11 Kraków',
      latitude: 50.0638,
      longitude: 19.9388
    )
    close_reviewed_result = GeocodingResult.create!(
      transformed_location: close_location,
      source: 'google',
      strategy: 'address_point',
      query: 'Długa 12 Kraków',
      latitude: 50.06441,
      longitude: 19.93941
    )
    google_reviewed_result = GeocodingResult.create!(
      transformed_location: google_location,
      source: 'google',
      strategy: 'address_point',
      query: 'Długa 13 Kraków',
      latitude: 50.0640,
      longitude: 19.9390
    )
    [
      [moved_location, moved_reviewed_result],
      [close_location, close_reviewed_result],
      [google_location, google_reviewed_result]
    ].each do |location, result|
      GeocodingReview.create!(
        transformed_location: location,
        signal_category: 'random_sample',
        review_status: 'exact',
        selected_geocoding_result: result,
        reviewed_at: Time.current
      )
    end

    locations = GeocodingReviewCandidateFinder
      .new
      .send(:random_sample_locations_for, 'random_sample_msip_regression')

    assert_includes locations, moved_location
    assert_not_includes locations, close_location
    assert_not_includes locations, google_location
  end

  test 'msip regression reviews are separate from original random sample reviews' do
    transformed_location = TransformedLocation.create!(
      address_1: 'Długa',
      building_number: '14',
      address_kind: 'street_address',
      latitude: 50.0645,
      longtitude: 19.9395,
      krakow_msip_latitude: 50.0645,
      krakow_msip_longitude: 19.9395,
      selected_geocoding_source: 'krakow_msip'
    )
    create_license_for(transformed_location, business_name: 'SEPARATE SAMPLE TEST')
    reviewed_result = GeocodingResult.create!(
      transformed_location: transformed_location,
      source: 'google',
      strategy: 'address_point',
      query: 'Długa 14 Kraków',
      latitude: 50.0640,
      longitude: 19.9390
    )
    GeocodingReview.create!(
      transformed_location: transformed_location,
      signal_category: 'random_sample',
      review_status: 'exact',
      selected_geocoding_result: reviewed_result,
      reviewed_at: Time.current
    )

    finder = GeocodingReviewCandidateFinder.new
    locations = finder.send(:random_sample_locations_for, 'random_sample_msip_regression')
    reviewed_ids = finder.send(:reviewed_location_ids_for, 'random_sample_msip_regression')

    assert_includes locations, transformed_location
    assert_not_includes reviewed_ids, transformed_location.id
  end

  test 'random sample keeps hard to tell locations in review queue until resolved' do
    hard_to_tell_location = TransformedLocation.create!(
      address_1: 'Długa',
      building_number: '15',
      address_kind: 'street_address',
      latitude: 50.0645,
      longtitude: 19.9395
    )
    resolved_location = TransformedLocation.create!(
      address_1: 'Długa',
      building_number: '16',
      address_kind: 'street_address',
      latitude: 50.0646,
      longtitude: 19.9396
    )
    create_license_for(hard_to_tell_location, business_name: 'HARD TO TELL SAMPLE TEST')
    create_license_for(resolved_location, business_name: 'RESOLVED SAMPLE TEST')

    GeocodingReview.create!(
      transformed_location: hard_to_tell_location,
      signal_category: 'random_sample',
      review_status: 'hard_to_tell',
      reviewed_at: Time.current
    )
    GeocodingReview.create!(
      transformed_location: resolved_location,
      signal_category: 'random_sample',
      review_status: 'exact',
      reviewed_at: Time.current
    )

    finder = GeocodingReviewCandidateFinder.new
    remaining = finder.send(:without_reviewed, [hard_to_tell_location, resolved_location], 'random_sample')

    assert_includes remaining, hard_to_tell_location
    assert_not_includes remaining, resolved_location
  end

end
