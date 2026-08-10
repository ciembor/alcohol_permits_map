class CreateLicensePointGroups < ActiveRecord::Migration[6.1]
  def change
    create_table :license_point_groups do |t|
      t.datetime :reported_at, null: false
      t.float :latitude, null: false
      t.float :longitude, null: false
      t.string :normalized_business_name, null: false
      t.string :display_business_name, null: false
      t.text :business_names, null: false
      t.text :business_ids, null: false
      t.float :similarity_floor, null: false, default: 1.0

      t.timestamps
    end

    add_index :license_point_groups, [:reported_at, :latitude, :longitude], name: 'index_license_point_groups_on_report_location'
    add_reference :alcohol_licenses, :license_point_group, foreign_key: true
  end
end
