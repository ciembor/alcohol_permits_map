class CreateLicenseCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :license_categories do |t|
      t.string :name
      t.string :description

      t.timestamps
    end
  end
end
