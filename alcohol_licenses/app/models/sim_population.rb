class SimPopulation < ApplicationRecord
  validates :observed_on, :observed_on_code, :sim_unit_code, :sim_unit_name,
    :district_code, :district_name, :total, presence: true
end
