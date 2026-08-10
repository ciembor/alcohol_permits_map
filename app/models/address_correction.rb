class AddressCorrection < ApplicationRecord
  belongs_to :location
  belongs_to :source_location, class_name: 'Location', optional: true

  scope :selected, -> { where(selected: true) }

  def address_parts
    {
      address_1: corrected_address_1,
      address_2: corrected_address_2
    }
  end
end
