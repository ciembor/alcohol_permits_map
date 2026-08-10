class AddSelectedGeocodingOriginToTransformedLocations < ActiveRecord::Migration[6.1]
  class MigrationTransformedLocation < ActiveRecord::Base
    self.table_name = 'transformed_locations'
  end

  class MigrationGeocodingResult < ActiveRecord::Base
    self.table_name = 'geocoding_results'
  end

  def up
    add_column :transformed_locations, :selected_geocoding_result_id, :integer
    add_column :transformed_locations, :selected_geocoding_source, :string
    add_column :transformed_locations, :selected_geocoding_strategy, :string
    add_column :transformed_locations, :selected_geocoding_precision, :string
    add_column :transformed_locations, :selected_geocoding_query, :string

    backfill_selected_geocoding_origin
  end

  def down
    remove_column :transformed_locations, :selected_geocoding_query
    remove_column :transformed_locations, :selected_geocoding_precision
    remove_column :transformed_locations, :selected_geocoding_strategy
    remove_column :transformed_locations, :selected_geocoding_source
    remove_column :transformed_locations, :selected_geocoding_result_id
  end

  private

  def backfill_selected_geocoding_origin
    MigrationTransformedLocation.reset_column_information

    MigrationGeocodingResult
      .where(selected: true)
      .order(id: :desc)
      .group_by(&:transformed_location_id)
      .each_value do |results|
        result = results.first
        MigrationTransformedLocation
          .where(id: result.transformed_location_id)
          .update_all(
            selected_geocoding_result_id: result.id,
            selected_geocoding_source: result.source,
            selected_geocoding_strategy: result.strategy,
            selected_geocoding_precision: result.precision,
            selected_geocoding_query: result.query
          )
      end
  end
end
