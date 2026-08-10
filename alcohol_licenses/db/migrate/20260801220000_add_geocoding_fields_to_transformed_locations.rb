class AddGeocodingFieldsToTransformedLocations < ActiveRecord::Migration[5.2]
  def change
    add_column :transformed_locations, :address_kind, :string
    add_column :transformed_locations, :address_relation, :string
    add_column :transformed_locations, :unit_number, :string
    add_column :transformed_locations, :parcel_number, :string
    add_column :transformed_locations, :raw_address_2, :string

    remove_index :transformed_locations, name: :index_transformed_locations_on_address_1_and_building_number
    add_index :transformed_locations,
      [:address_1, :building_number, :address_kind, :address_relation, :unit_number, :parcel_number],
      unique: true,
      name: :index_transformed_locations_on_geocoding_identity
  end
end
