class CreateTransformedLocations < ActiveRecord::Migration[5.2]
  def change
    create_table :transformed_locations do |t|
      t.string :address_1
      t.string :building_number
      t.float :latitude
      t.float :longtitude

      t.timestamps
    end

    add_index :transformed_locations, [:address_1, :building_number], unique: true
    add_reference :locations, :transformed_location, foreign_key: true
  end
end
