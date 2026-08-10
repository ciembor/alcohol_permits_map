class AddOsmGeocodingFieldsToTransformedLocations < ActiveRecord::Migration[6.1]
  def change
    add_column :transformed_locations, :osm_latitude, :float
    add_column :transformed_locations, :osm_longitude, :float
    add_column :transformed_locations, :osm_geocoding_strategy, :string
    add_column :transformed_locations, :osm_geocoding_precision, :string
    add_column :transformed_locations, :osm_geocoding_query, :string
  end
end
