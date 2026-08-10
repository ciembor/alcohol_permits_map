class CreateAlcoholLicenses < ActiveRecord::Migration[5.2]
  def change
    create_table :alcohol_licenses do |t|
      t.datetime :expires_at
      t.datetime :reported_at

      t.references :business_category, foreign_key: true
      t.references :license_category, foreign_key: true
      t.references :location, foreign_key: true
      t.references :business, foreign_key: true

      t.timestamps
    end
  end
end
