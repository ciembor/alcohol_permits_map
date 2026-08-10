class Location < ApplicationRecord
  has_many :alcohol_licenses
  has_many :address_corrections
  belongs_to :transformed_location, optional: true

  def selected_address_correction
    address_corrections.selected.order(confidence: :desc, id: :desc).first
  end
end
