require 'test_helper'
require 'csv'
require 'json'
require 'tmpdir'

class DatasetExport::GeocodingReviewsExporterTest < ActiveSupport::TestCase
  setup do
    clear_dataset_records
    seed_geocoding_review_records
  end

  teardown do
    clear_dataset_records
  end

  test 'writes geocoding review rows with public references and without reviewer notes' do
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'geocoding_reviews.csv')
      count = DatasetExport::Exporters::GeocodingReviewsExporter.new(path: path).write

      assert_equal 2, count

      csv = CSV.read(path, headers: true, encoding: 'UTF-8')
      assert_equal DatasetExport::GeocodingReviewRows::COLUMNS, csv.headers
      assert_equal 2, csv.map { |row| row.fetch('review_id') }.uniq.size
      assert csv.all? { |row| row.fetch('review_id').start_with?('geocoding-review-') }

      manual = csv.find { |row| row.fetch('review_status') == 'corrected' }
      refute_includes csv.headers, 'reviewed_by'
      refute_includes csv.headers, 'note'
      assert manual.fetch('normalized_location_id').start_with?('normalized-location-')
      assert manual.fetch('selected_geocoding_result_id').start_with?('geocoding-result-')
      assert manual.fetch('manual_geocoding_result_id').start_with?('geocoding-result-')
      assert_equal ['distance_warning'], JSON.parse(manual.fetch('quality_signals'))

      google_selected = csv.find { |row| row.fetch('review_status') == 'exact' }
      assert_nil google_selected.fetch('selected_geocoding_result_id')
    end
  end

  test 'latest only limits reviews to locations used in newest report' do
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'geocoding_reviews.csv')
      count = DatasetExport::Exporters::GeocodingReviewsExporter.new(path: path, latest_only: true).write

      assert_equal 1, count
      csv = CSV.read(path, headers: true, encoding: 'UTF-8')
      assert_equal ['exact'], csv.map { |row| row.fetch('review_status') }
    end
  end

  private

  def seed_geocoding_review_records
    detail = BusinessCategory.create!(name: 'detal')
    category_a = LicenseCategory.create!(name: 'A', description: 'A')
    business = Business.create!(name: 'TEST BUSINESS')
    old_location = TransformedLocation.create!(
      address_1: 'Rynek',
      building_number: '1',
      address_kind: 'street_address'
    )
    latest_location = TransformedLocation.create!(
      address_1: 'Długa',
      building_number: '2',
      address_kind: 'street_address'
    )
    old_raw = Location.create!(address_1: 'RYNEK', address_2: '1', transformed_location: old_location)
    latest_raw = Location.create!(address_1: 'DŁUGA', address_2: '2', transformed_location: latest_location)
    selected = GeocodingResult.create!(
      transformed_location: old_location,
      source: 'krakow_msip',
      strategy: 'address_point',
      query: 'Rynek 1 Kraków',
      latitude: 50.061,
      longitude: 19.936,
      selected: true,
      created_at: Time.utc(2026, 1, 1),
      updated_at: Time.utc(2026, 1, 1)
    )
    manual = GeocodingResult.create!(
      transformed_location: old_location,
      source: 'manual_review',
      strategy: 'address_point',
      query: 'Rynek 1 Kraków',
      latitude: 50.062,
      longitude: 19.937,
      selected: false,
      created_at: Time.utc(2026, 1, 2),
      updated_at: Time.utc(2026, 1, 2)
    )
    google = GeocodingResult.create!(
      transformed_location: latest_location,
      source: 'google',
      strategy: 'address_point',
      query: 'Długa 2 Kraków',
      latitude: 50.07,
      longitude: 19.94,
      selected: true,
      created_at: Time.utc(2026, 1, 3),
      updated_at: Time.utc(2026, 1, 3)
    )

    GeocodingReview.create!(
      transformed_location: old_location,
      signal_category: 'manual',
      review_status: 'corrected',
      reviewed_by: 'reviewer@example.com',
      original_latitude: 50.061,
      original_longitude: 19.936,
      manual_latitude: 50.062,
      manual_longitude: 19.937,
      selected_geocoding_result: selected,
      manual_geocoding_result: manual,
      quality_signals: ['distance_warning'],
      note: 'manual correction',
      sim_circle_within_area: true,
      reviewed_at: Time.utc(2026, 1, 3)
    )
    GeocodingReview.create!(
      transformed_location: latest_location,
      signal_category: 'manual',
      review_status: 'exact',
      selected_geocoding_result: google,
      quality_signals: [],
      sim_circle_within_area: false,
      reviewed_at: Time.utc(2026, 1, 4)
    )

    AlcoholLicense.create!(
      reported_at: Time.utc(2026, 1, 1),
      business_category: detail,
      license_category: category_a,
      business: business,
      location: old_raw
    )
    AlcoholLicense.create!(
      reported_at: Time.utc(2026, 2, 1),
      business_category: detail,
      license_category: category_a,
      business: business,
      location: latest_raw
    )
  end

  def clear_dataset_records
    AlcoholLicense.delete_all
    GeocodingReview.delete_all
    GeocodingResult.delete_all
    Location.delete_all
    TransformedLocation.delete_all
    Business.delete_all
    BusinessCategory.delete_all
    LicenseCategory.delete_all
  end
end
