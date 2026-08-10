class LicensePointGroup < ApplicationRecord
  has_many :alcohol_licenses, dependent: :nullify

  serialize :business_names, Array
  serialize :business_ids, Array
end
