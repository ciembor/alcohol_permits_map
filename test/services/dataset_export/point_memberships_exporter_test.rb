require 'test_helper'
require 'csv'
require 'tmpdir'

class DatasetExport::PointMembershipsExporterTest < ActiveSupport::TestCase
  setup do
    clear_dataset_records
    seed_membership_records
  end

  teardown do
    clear_dataset_records
  end

  test 'writes point membership rows for grouped, fallback and ungeocoded licenses' do
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'point_memberships.csv')
      count = DatasetExport::Exporters::PointMembershipsExporter.new(path: path).write

      assert_equal 4, count

      csv = CSV.read(path, headers: true, encoding: 'UTF-8')
      assert_equal DatasetExport::MembershipRows::COLUMNS, csv.headers
      assert_empty csv.headers.grep(/\Ainternal_/)
      assert_equal %w[fallback_business_location license_point_group not_geocoded], csv.map { |row| row.fetch('membership_method') }.uniq.sort
      assert_equal 4, csv.map { |row| row.fetch('license_id') }.uniq.size
      assert_equal 1, csv.count { |row| row.fetch('membership_method') == 'not_geocoded' && row.fetch('point_id').blank? }
    end
  end

  test 'membership license and point ids match exported alcohol license rows' do
    memberships = DatasetExport::MembershipRows.new.each.to_a.index_by { |row| row.fetch('license_id') }
    license_rows = DatasetExport::LicenseRows.new.each.to_a

    license_rows.each do |license_row|
      membership = memberships.fetch(license_row.fetch('license_id'))

      if license_row.fetch('point_id').nil?
        assert_nil membership.fetch('point_id')
      else
        assert_equal license_row.fetch('point_id'), membership.fetch('point_id')
      end
      assert_equal license_row.fetch('report_id'), membership.fetch('report_id')
    end
  end

  test 'latest only limits memberships to the newest report' do
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'point_memberships.csv')
      count = DatasetExport::Exporters::PointMembershipsExporter.new(path: path, latest_only: true).write

      assert_equal 1, count
      csv = CSV.read(path, headers: true, encoding: 'UTF-8')
      assert_equal ['not_geocoded'], csv.map { |row| row.fetch('membership_method') }
    end
  end

  private

  def seed_membership_records
    report = Time.utc(2026, 1, 1)
    latest_report = Time.utc(2026, 2, 1)
    detail = BusinessCategory.create!(name: 'detal')
    gastronomy = BusinessCategory.create!(name: 'gastronomia')
    category_a = LicenseCategory.create!(name: 'A', description: 'A')
    category_b = LicenseCategory.create!(name: 'B', description: 'B')
    business = Business.create!(name: 'TEST BUSINESS')
    fallback_business = Business.create!(name: 'FALLBACK BUSINESS')
    transformed = TransformedLocation.create!(
      address_1: 'Rynek',
      building_number: '1',
      address_kind: 'street_address',
      latitude: 50.061,
      longtitude: 19.936
    )
    fallback_transformed = TransformedLocation.create!(
      address_1: 'Długa',
      building_number: '2',
      address_kind: 'street_address',
      latitude: 50.07,
      longtitude: 19.94
    )
    raw = Location.create!(address_1: 'RYNEK', address_2: '1', transformed_location: transformed)
    fallback_raw = Location.create!(address_1: 'DŁUGA', address_2: '2', transformed_location: fallback_transformed)
    ungeocoded_raw = Location.create!(address_1: 'BRAK', address_2: '1')
    group = LicensePointGroup.create!(
      reported_at: report,
      latitude: 50.061,
      longitude: 19.936,
      normalized_business_name: 'TEST BUSINESS',
      display_business_name: 'TEST BUSINESS',
      business_names: ['TEST BUSINESS'],
      business_ids: [business.id],
      similarity_floor: 1.0
    )

    AlcoholLicense.create!(
      reported_at: report,
      business_category: detail,
      license_category: category_a,
      business: business,
      location: raw,
      license_point_group: group
    )
    AlcoholLicense.create!(
      reported_at: report,
      business_category: gastronomy,
      license_category: category_b,
      business: business,
      location: raw,
      license_point_group: group
    )
    AlcoholLicense.create!(
      reported_at: report,
      business_category: detail,
      license_category: category_a,
      business: fallback_business,
      location: fallback_raw
    )
    AlcoholLicense.create!(
      reported_at: latest_report,
      business_category: detail,
      license_category: category_a,
      business: business,
      location: ungeocoded_raw
    )
  end

  def clear_dataset_records
    AlcoholLicense.delete_all
    LicensePointGroup.delete_all
    Location.delete_all
    TransformedLocation.delete_all
    Business.delete_all
    BusinessCategory.delete_all
    LicenseCategory.delete_all
  end
end
