require 'test_helper'
require 'ostruct'

class LicensePointGroupBuilderTest < ActiveSupport::TestCase
  test 'matches businesses with the same normalized token key' do
    builder = LicensePointGroupBuilder.new(Time.zone.now)

    assert builder.send(
      :similar_business?,
      business('KAROLINA PACH'),
      business('PACH KAROLINA')
    )
  end

  test 'matches configured business aliases' do
    builder = LicensePointGroupBuilder.new(Time.zone.now)

    assert builder.send(
      :similar_business?,
      business('GRUPA SCANDALE PAJDA, KLESYK SPÓŁKA JAWNA'),
      business('GRUPA A & G PAJDA KLESYK SPÓŁKA JAWNA')
    )
  end

  test 'does not match generic token subsets' do
    builder = LicensePointGroupBuilder.new(Time.zone.now)

    refute builder.send(
      :similar_business?,
      business('KŁOBUCH MAREK'),
      business('KŁOBUCH MAREK, KŁOBUCH MARZENA')
    )
  end

  test 'does not match businesses that differ by meaningful qualifiers' do
    builder = LicensePointGroupBuilder.new(Time.zone.now)

    refute builder.send(
      :similar_business?,
      business('BONUS DEVELOPMENT SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ SPÓŁKA KOMANDYTOWA'),
      business('BONUS MANAGEMENT SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ SPÓŁKA KOMANDYTOWA')
    )
    refute builder.send(
      :similar_business?,
      business('WINE GARAGE GROUP SPÓŁKA Z O.O.'),
      business('WINE GARAGE SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ SPÓŁKA KOMANDYTOWA')
    )
  end

  test 'does not group matching businesses in different unit numbers' do
    builder = LicensePointGroupBuilder.new(Time.zone.now)
    licenses = [
      license(1, 10, 'KAROLINA PACH', 50.0, 19.0, '1'),
      license(2, 11, 'PACH KAROLINA', 50.0, 19.0, '2')
    ]

    groups = builder.send(:build_groups, licenses)

    assert_equal 2, groups.size
    assert_equal [[1], [2]], groups.map { |group| group.fetch(:license_ids) }.sort
  end

  test 'groups matching businesses in the same unit number' do
    builder = LicensePointGroupBuilder.new(Time.zone.now)
    licenses = [
      license(1, 10, 'KAROLINA PACH', 50.0, 19.0, '1'),
      license(2, 11, 'PACH KAROLINA', 50.0, 19.0, '1')
    ]

    groups = builder.send(:build_groups, licenses)

    assert_equal 1, groups.size
    assert_equal [1, 2], groups.first.fetch(:license_ids).sort
  end

  private

  def license(id, business_id, business_name, latitude, longitude, unit_number)
    OpenStruct.new(
      id: id,
      business_id: business_id,
      business_name: business_name,
      latitude: latitude,
      longitude: longitude,
      unit_number: unit_number
    )
  end

  def business(name)
    {
      normalized_name: BusinessNameNormalizer.normalize(name),
      normalized_token_key: BusinessNameNormalizer.normalized_token_key(name)
    }
  end
end
