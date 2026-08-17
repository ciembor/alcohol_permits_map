class LicensePointGroup < ApplicationRecord
  has_many :alcohol_licenses, dependent: :nullify

  serialize :business_names, coder: YAML, type: Array
  serialize :business_ids, coder: YAML, type: Array
end
