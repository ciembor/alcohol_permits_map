require 'test_helper'

class AddressCorrectionTest < ActiveSupport::TestCase
  test 'returns corrected address parts' do
    location = Location.create!(address_1: 'DŁUGA')
    correction = AddressCorrection.create!(
      location: location,
      corrected_address_1: 'DŁUGA',
      corrected_address_2: '10',
      source: 'test',
      method: 'manual',
      confidence: 1.0,
      selected: true
    )

    assert_equal({ address_1: 'DŁUGA', address_2: '10' }, correction.address_parts)
    assert_equal correction, location.selected_address_correction
  end
end
