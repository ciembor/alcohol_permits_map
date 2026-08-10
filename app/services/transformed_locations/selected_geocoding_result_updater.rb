module TransformedLocations
  class SelectedGeocodingResultUpdater
    def initialize(location)
      @location = location
    end

    def use!(result)
      location.update!(
        latitude: result.latitude,
        longtitude: result.longitude,
        selected_geocoding_result_id: result.id,
        selected_geocoding_source: result.source,
        selected_geocoding_strategy: result.strategy,
        selected_geocoding_precision: result.precision,
        selected_geocoding_query: result.query
      )
    end

    private

    attr_reader :location
  end
end
