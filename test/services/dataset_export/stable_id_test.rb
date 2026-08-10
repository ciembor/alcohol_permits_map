require 'test_helper'

class DatasetExport::StableIdTest < ActiveSupport::TestCase
  test 'report id is stable and readable' do
    assert_equal 'report-2026-02-06T08-43-09Z', DatasetExport::StableId.report_id(Time.utc(2026, 2, 6, 8, 43, 9))
  end

  test 'hash ids are deterministic and scoped' do
    first = DatasetExport::StableId.raw_location_id(source_address_1: ' Florianska ', source_address_2: ' 20 ')
    second = DatasetExport::StableId.raw_location_id(source_address_1: 'Florianska', source_address_2: '20')

    assert_equal first, second
    assert_match(/\Araw-location-[0-9a-f]{16}\z/, first)
  end

  test 'license id normalizes time and whitespace' do
    first = DatasetExport::StableId.license_id(
      reported_at: Time.utc(2026, 2, 6, 8, 43, 9),
      business_category: 'detal',
      license_category: 'A',
      business_name: 'ABC  SP. Z O.O.',
      source_address_1: 'Rynek  Glowny',
      source_address_2: '1',
      expires_at: Date.new(2026, 12, 31)
    )
    second = DatasetExport::StableId.license_id(
      reported_at: '2026-02-06 08:43:09 UTC',
      business_category: 'detal',
      license_category: 'A',
      business_name: 'ABC SP. Z O.O.',
      source_address_1: 'Rynek Glowny',
      source_address_2: '1',
      expires_at: '2026-12-31'
    )

    assert_equal first, second
    assert_match(/\Alicense-[0-9a-f]{16}\z/, first)
  end

  test 'point id does not expose business name' do
    point_id = DatasetExport::StableId.point_id(
      reported_at: Time.utc(2026, 2, 6, 8, 43, 9),
      normalized_location_id: 'normalized-location-abc',
      unit_number: '2',
      normalized_business_name: 'SENSITIVE BUSINESS NAME'
    )

    assert_match(/\Apoint-[0-9a-f]{16}\z/, point_id)
    refute_includes point_id, 'SENSITIVE'
  end
end

