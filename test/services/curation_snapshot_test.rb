require 'test_helper'
require 'tmpdir'

class CurationSnapshotTest < ActiveSupport::TestCase
  test 'exports and imports curated corrections reviews and selected geocoding' do
    raw = Location.create!(address_1: 'DŁUGA', address_2: '1')
    transformed = TransformedLocation.create!(
      address_1: 'Długa',
      building_number: '1',
      address_kind: 'street_address',
      raw_address_2: '1'
    )
    raw.update!(transformed_location: transformed)
    AddressCorrection.create!(
      location: raw,
      corrected_address_1: 'DŁUGA',
      corrected_address_2: '1A',
      source: 'manual',
      method: 'review',
      confidence: 1.0,
      selected: true,
      evidence: 'checked'
    )
    selected = GeocodingResult.create!(
      transformed_location: transformed,
      source: 'krakow_msip',
      strategy: 'address_point',
      query: 'Długa 1 Kraków',
      latitude: 50.061,
      longitude: 19.936,
      confidence: 1.0,
      precision: 'address_point/building',
      selected: true
    )
    transformed.use_geocoding_result!(selected)
    GeocodingReview.create!(
      transformed_location: transformed,
      signal_category: 'random_sample',
      review_status: 'exact',
      selected_geocoding_result: selected,
      quality_signals: ['sample'],
      note: 'ok',
      reviewed_at: Time.utc(2026, 1, 1)
    )

    Dir.mktmpdir do |dir|
      path = File.join(dir, 'curation.json')
      CurationSnapshot.export!(path: path)

      GeocodingReview.delete_all
      GeocodingResult.delete_all
      AddressCorrection.delete_all
      transformed.update!(
        latitude: nil,
        longtitude: nil,
        selected_geocoding_result_id: nil,
        selected_geocoding_source: nil
      )

      result = CurationSnapshot.import!(path: path)

      assert_equal 1, result.fetch(:address_corrections)
      assert_equal 1, result.fetch(:selected_geocoding_results)
      assert_equal 1, result.fetch(:geocoding_reviews)
      assert_equal '1A', raw.address_corrections.selected.first.corrected_address_2
      assert_equal 'krakow_msip', transformed.reload.selected_geocoding_source
      assert_equal ['sample'], transformed.geocoding_reviews.first.quality_signals
    end
  end
end
