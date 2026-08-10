require 'test_helper'
require 'location_transformer/address_correction_inferer'

class LocationTransformer::AddressCorrectionInfererTest < ActiveSupport::TestCase
  setup do
    Street.create!(name_1: 'Długa')
    @business = Business.create!(name: 'TEST BUSINESS')
    @license_category = LicenseCategory.create!(name: 'A')
    @business_category = BusinessCategory.create!(name: 'detal')
  end

  test 'infers correction from the same business on the same normalized street' do
    blank_location = Location.create!(address_1: 'DŁUGA')
    source_location = Location.create!(address_1: 'DŁUGA', address_2: '10 lok. 2')
    create_license(blank_location)
    create_license(source_location)

    correction = LocationTransformer::AddressCorrectionInferer.new.infer(blank_location)

    assert correction.selected?
    assert_equal blank_location, correction.location
    assert_equal source_location, correction.source_location
    assert_equal 'DŁUGA', correction.corrected_address_1
    assert_equal '10 lok. 2', correction.corrected_address_2
    assert_equal 'internal_history', correction.source
  end

  test 'does not infer when there are multiple candidate addresses' do
    blank_location = Location.create!(address_1: 'DŁUGA')
    create_license(blank_location)
    create_license(Location.create!(address_1: 'DŁUGA', address_2: '10'))
    create_license(Location.create!(address_1: 'DŁUGA', address_2: '11'))

    assert_nil LocationTransformer::AddressCorrectionInferer.new.infer(blank_location)
  end

  private

  def create_license(location)
    AlcoholLicense.create!(
      business: @business,
      business_category: @business_category,
      license_category: @license_category,
      location: location
    )
  end
end
