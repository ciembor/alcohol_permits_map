class AddCadastralRegionToTransformedLocations < ActiveRecord::Migration[5.2]
  def change
    add_column :transformed_locations, :parcel_region, :string
    add_column :transformed_locations, :parcel_cadastral_unit, :string

    remove_index :transformed_locations, name: "index_transformed_locations_on_geocoding_identity"
    add_index :transformed_locations,
      [:address_1, :building_number, :address_kind, :address_relation, :unit_number, :parcel_number, :parcel_region, :parcel_cadastral_unit],
      unique: true,
      name: "index_transformed_locations_on_geocoding_identity"
  end
end
