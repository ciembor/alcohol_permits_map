class AddSourceCoordinatesToTransformedLocations < ActiveRecord::Migration[6.1]
  class MigrationTransformedLocation < ActiveRecord::Base
    self.table_name = 'transformed_locations'
  end

  class MigrationGeocodingResult < ActiveRecord::Base
    self.table_name = 'geocoding_results'
  end

  SOURCE_COLUMNS = {
    'krakow_msip' => [:krakow_msip_latitude, :krakow_msip_longitude],
    'gus' => [:gus_latitude, :gus_longitude],
    'nominatim' => [:nominatim_latitude, :nominatim_longitude],
    'google' => [:google_latitude, :google_longitude],
    'uldk' => [:uldk_latitude, :uldk_longitude]
  }.freeze

  def up
    add_column :transformed_locations, :krakow_msip_latitude, :float
    add_column :transformed_locations, :krakow_msip_longitude, :float
    add_column :transformed_locations, :gus_latitude, :float
    add_column :transformed_locations, :gus_longitude, :float
    add_column :transformed_locations, :nominatim_latitude, :float
    add_column :transformed_locations, :nominatim_longitude, :float
    add_column :transformed_locations, :google_latitude, :float
    add_column :transformed_locations, :google_longitude, :float
    add_column :transformed_locations, :uldk_latitude, :float
    add_column :transformed_locations, :uldk_longitude, :float

    backfill_source_coordinates
  end

  def down
    remove_column :transformed_locations, :krakow_msip_latitude
    remove_column :transformed_locations, :krakow_msip_longitude
    remove_column :transformed_locations, :gus_latitude
    remove_column :transformed_locations, :gus_longitude
    remove_column :transformed_locations, :nominatim_latitude
    remove_column :transformed_locations, :nominatim_longitude
    remove_column :transformed_locations, :google_latitude
    remove_column :transformed_locations, :google_longitude
    remove_column :transformed_locations, :uldk_latitude
    remove_column :transformed_locations, :uldk_longitude
  end

  private

  def backfill_source_coordinates
    MigrationTransformedLocation.reset_column_information

    SOURCE_COLUMNS.each do |source, (latitude_column, longitude_column)|
      MigrationGeocodingResult
        .where(source: source)
        .where.not(latitude: nil, longitude: nil)
        .order(selected: :desc, id: :desc)
        .group_by(&:transformed_location_id)
        .each_value do |results|
          result = results.first
          MigrationTransformedLocation
            .where(id: result.transformed_location_id)
            .update_all(latitude_column => result.latitude, longitude_column => result.longitude)
        end
    end
  end
end
