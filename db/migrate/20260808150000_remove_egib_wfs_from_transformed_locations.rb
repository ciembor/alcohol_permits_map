class RemoveEgibWfsFromTransformedLocations < ActiveRecord::Migration[6.1]
  class MigrationGeocodingResult < ActiveRecord::Base
    self.table_name = 'geocoding_results'
  end

  def up
    MigrationGeocodingResult.where(source: 'egib_wfs').delete_all if table_exists?(:geocoding_results)
    remove_column :transformed_locations, :egib_wfs_latitude, :float if column_exists?(:transformed_locations, :egib_wfs_latitude)
    remove_column :transformed_locations, :egib_wfs_longitude, :float if column_exists?(:transformed_locations, :egib_wfs_longitude)
  end

  def down
    add_column :transformed_locations, :egib_wfs_latitude, :float unless column_exists?(:transformed_locations, :egib_wfs_latitude)
    add_column :transformed_locations, :egib_wfs_longitude, :float unless column_exists?(:transformed_locations, :egib_wfs_longitude)
  end
end
