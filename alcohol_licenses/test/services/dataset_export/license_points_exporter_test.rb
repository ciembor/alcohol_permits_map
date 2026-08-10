require 'test_helper'
require 'csv'
require 'json'
require 'ostruct'
require 'tmpdir'

class DatasetExport::LicensePointsExporterTest < ActiveSupport::TestCase
  setup do
    clear_dataset_records
    seed_point_records
  end

  teardown do
    clear_dataset_records
  end

  test 'writes grouped point rows without business names by default' do
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'license_points.csv')
      count = DatasetExport::Exporters::LicensePointsExporter.new(path: path).write

      assert_equal 1, count

      csv = CSV.read(path, headers: true, encoding: 'UTF-8')
      assert_equal DatasetExport::PointRows::COLUMNS, csv.headers
      row = csv.first
      assert_equal DatasetExport::StableId.group_point_id(
        reported_at: @report,
        latitude: 50.061,
        longitude: 19.936,
        normalized_business_name: 'TEST BUSINESS',
        internal_group_id: @group.id
      ), row.fetch('point_id')
      assert_equal '2', row.fetch('license_count')
      assert_equal '1', row.fetch('license_count_a')
      assert_equal '1', row.fetch('license_count_b')
      assert_equal '1', row.fetch('retail_license_count')
      assert_equal '1', row.fetch('gastronomy_license_count')
      assert_equal 'true', row.fetch('mixed_flag')
      assert_equal ['A', 'B'], JSON.parse(row.fetch('license_categories'))
      assert_equal ['detal', 'gastronomia'], JSON.parse(row.fetch('business_categories'))
      assert row.fetch('normalized_location_id').start_with?('normalized-location-')
      assert row.fetch('raw_location_ids').present?
      refute_includes csv.headers, 'business_names'
    end
  end

  test 'can include business names explicitly' do
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'license_points.csv')
      DatasetExport::Exporters::LicensePointsExporter.new(path: path, include_business_names: true).write

      csv = CSV.read(path, headers: true, encoding: 'UTF-8')
      assert_includes csv.headers, 'display_business_name'
      assert_includes csv.headers, 'business_names'
      assert_equal 'TEST BUSINESS', csv.first.fetch('display_business_name')
      assert_equal ['TEST BUSINESS'], JSON.parse(csv.first.fetch('business_names'))
    end
  end

  test 'point id matches alcohol license rows for grouped licenses' do
    point_id = DatasetExport::PointRows.new.each.first.fetch('point_id')
    license_point_ids = DatasetExport::LicenseRows.new.each.map { |row| row.fetch('point_id') }.compact.uniq

    assert_equal [point_id], license_point_ids
  end

  test 'exports fallback point for geocoded license without persisted group' do
    business = Business.create!(name: 'UNGROUPED BUSINESS')
    raw = Location.create!(address_1: 'DŁUGA', address_2: '2', transformed_location: TransformedLocation.create!(
      address_1: 'Długa',
      building_number: '2',
      address_kind: 'street_address',
      latitude: 50.07,
      longtitude: 19.94
    ))

    AlcoholLicense.create!(
      reported_at: @report,
      business_category: BusinessCategory.find_by!(name: 'detal'),
      license_category: LicenseCategory.find_by!(name: 'A'),
      business: business,
      location: raw
    )

    point_rows = DatasetExport::PointRows.new.each.to_a
    license_rows = DatasetExport::LicenseRows.new.each.to_a
    fallback_point = point_rows.find { |row| row.fetch('internal_license_point_group_id').blank? }

    assert fallback_point
    assert_equal '1', fallback_point.fetch('license_count').to_s
    assert_includes license_rows.map { |row| row.fetch('point_id') }, fallback_point.fetch('point_id')
  end

  private

  def seed_point_records
    @report = Time.utc(2026, 1, 1)
    detail = BusinessCategory.create!(name: 'detal')
    gastronomy = BusinessCategory.create!(name: 'gastronomia')
    category_a = LicenseCategory.create!(name: 'A', description: 'A')
    category_b = LicenseCategory.create!(name: 'B', description: 'B')
    business = Business.create!(name: 'TEST BUSINESS')
    transformed = TransformedLocation.create!(
      address_1: 'Rynek',
      building_number: '1',
      address_kind: 'street_address',
      latitude: 50.061,
      longtitude: 19.936
    )
    raw = Location.create!(address_1: 'RYNEK', address_2: '1', transformed_location: transformed)
    @group = LicensePointGroup.create!(
      reported_at: @report,
      latitude: 50.061,
      longitude: 19.936,
      normalized_business_name: 'TEST BUSINESS',
      display_business_name: 'TEST BUSINESS',
      business_names: ['TEST BUSINESS'],
      business_ids: [business.id],
      similarity_floor: 1.0
    )

    AlcoholLicense.create!(
      reported_at: @report,
      expires_at: Date.new(2026, 12, 31),
      business_category: detail,
      license_category: category_a,
      business: business,
      location: raw,
      license_point_group: @group
    )
    AlcoholLicense.create!(
      reported_at: @report,
      expires_at: Date.new(2027, 12, 31),
      business_category: gastronomy,
      license_category: category_b,
      business: business,
      location: raw,
      license_point_group: @group
    )
  end

  def clear_dataset_records
    AlcoholLicense.delete_all
    LicensePointGroup.delete_all
    Location.delete_all
    TransformedLocation.delete_all
    GeocodingReview.delete_all if defined?(GeocodingReview)
    Business.delete_all
    BusinessCategory.delete_all
    LicenseCategory.delete_all
  end
end
