module Geocoding
  class OsmLocationSync
    SOURCE = 'nominatim'.freeze
    STRATEGY_PRIORITY = {
      'address_point' => 5,
      'described_place' => 4,
      'teryt_named_object' => 3,
      'street_fallback' => 2,
      'cadastral_parcel' => 1
    }.freeze

    def self.sync!(scope = TransformedLocation.all)
      new(scope).sync!
    end

    def initialize(scope)
      @scope = scope
    end

    def sync!
      updated = 0
      missing = 0

      scope.find_each do |transformed_location|
        result = best_osm_result(transformed_location)
        if result
          transformed_location.update!(
            osm_latitude: result.latitude,
            osm_longitude: result.longitude,
            osm_geocoding_strategy: result.strategy,
            osm_geocoding_precision: result.precision,
            osm_geocoding_query: result.query
          )
          updated += 1
        else
          transformed_location.update!(
            osm_latitude: nil,
            osm_longitude: nil,
            osm_geocoding_strategy: nil,
            osm_geocoding_precision: nil,
            osm_geocoding_query: nil
          )
          missing += 1
        end
      end

      { updated: updated, missing: missing }
    end

    private

    attr_reader :scope

    def best_osm_result(transformed_location)
      transformed_location
        .geocoding_results
        .where(source: SOURCE)
        .where.not(latitude: nil, longitude: nil)
        .to_a
        .max_by { |result| [strategy_priority(result.strategy), precision_priority(result.precision), result.id] }
    end

    def strategy_priority(strategy)
      STRATEGY_PRIORITY.fetch(strategy.to_s, 0)
    end

    def precision_priority(precision)
      value = precision.to_s
      return 5 if value.match?(%r{/(building|house|apartments|retail|commercial)\z})
      return 4 if value.include?('/amenity')
      return 3 if value.include?('/road')

      1
    end
  end
end
