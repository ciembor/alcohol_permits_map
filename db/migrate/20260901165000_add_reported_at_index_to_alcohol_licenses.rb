class AddReportedAtIndexToAlcoholLicenses < ActiveRecord::Migration[6.1]
  def change
    add_index :alcohol_licenses, :reported_at
  end
end
