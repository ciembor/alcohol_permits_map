module TransformedLocations
  class GeocodingProfile
    CITY = 'Kraków'.freeze
    CADASTRAL_UNITS = {
      'krowodrza' => 'Krowodrza',
      'nowa_huta' => 'Nowa Huta',
      'podgorze' => 'Podgórze',
      'srodmiescie' => 'Śródmieście'
    }.freeze

    def initialize(location)
      @location = location
    end

    def geocodable?
      queries.any?
    end

    def address
      first_query&.fetch(:query)
    end

    def strategy
      first_query&.fetch(:strategy)
    end

    def payload
      {
        address: address,
        strategy: strategy,
        city: CITY,
        street: location.address_1,
        building_number: location.building_number,
        unit_number: location.unit_number,
        parcel_number: location.parcel_number,
        parcel_region: location.parcel_region,
        parcel_cadastral_unit: location.parcel_cadastral_unit,
        address_kind: location.address_kind,
        address_relation: location.address_relation,
        raw_address_2: location.raw_address_2,
        same_as: same_as_values
      }
    end

    def queries
      return [] if location.address_1.blank?

      [
        *address_point_queries,
        *parcel_queries,
        *described_place_queries,
        *teryt_named_object_queries,
        street_fallback_query
      ].uniq { |query| [query[:strategy], query[:query]] }
    end

    private

    attr_reader :location

    def first_query
      queries.first
    end

    def address_point_queries
      return [] unless location.building_number.present?

      preferred_address_point_streets.map do |street|
        geocoding_query('address_point', [street, location.building_number, CITY], street: street, number: location.building_number)
      end + fallback_address_point_streets.map do |street|
        geocoding_query('historical_address_point', [street, location.building_number, CITY], street: street, number: location.building_number)
      end
    end

    def preferred_address_point_streets
      same_as_values.presence || [location.address_1]
    end

    def fallback_address_point_streets
      return [] if same_as_values.empty?

      [location.address_1]
    end

    def parcel_queries
      return [] unless location.address_kind == 'parcel' && location.parcel_number.present?

      parcel_region_values.flat_map do |parcel_region|
        parcel_number_values.map do |parcel_number|
          geocoding_query('cadastral_parcel', parcel_query_parts(parcel_number, parcel_region))
        end
      end
    end

    def described_place_queries
      described_place_values.map do |description|
        geocoding_query('described_place', [description, location.address_1, CITY])
      end
    end

    def teryt_named_object_queries
      return [] unless location.address_kind == 'landmark' && Street.exists?(trait: 'inne', name_1: location.address_1)

      [geocoding_query('teryt_named_object', [location.address_1, CITY])]
    end

    def street_fallback_query
      geocoding_query('street_fallback', [location.address_1, CITY])
    end

    def geocoding_query(strategy, parts, street: nil, number: nil)
      {
        strategy: strategy,
        query: parts.compact.join(' ')
      }.tap do |query|
        query[:street] = street if street.present?
        query[:number] = number if number.present?
      end
    end

    def same_as_values
      location.same_as.to_s.split('|').map { |value| normalize_value(value) }.reject(&:blank?).uniq
    end

    def parcel_number_values
      location.parcel_number.to_s.split('|').map { |value| normalize_value(value) }.reject(&:blank?).uniq
    end

    def parcel_region_values
      values = location.parcel_region.to_s.split('|').map { |value| normalize_value(value) }.reject(&:blank?).uniq
      values.presence || [nil]
    end

    def parcel_query_parts(parcel_number_value, parcel_region_value)
      [
        location.address_1,
        "dz. #{parcel_number_value}",
        parcel_region_value.present? ? "obr. #{parcel_region_value}" : nil,
        CADASTRAL_UNITS[location.parcel_cadastral_unit],
        CITY
      ]
    end

    def described_place_values
      values = source_address_2_values
      values << "pawilon #{location.unit_number}" if location.address_kind == 'pavilion' && location.unit_number.present?
      values.uniq
    end

    def source_address_2_values
      values = []
      values << location.raw_address_2 if location.raw_address_2.present?
      values.concat(location.locations.map(&:address_2)) if location.persisted?

      values.map { |value| normalize_value(value) }.reject(&:blank?)
    end

    def normalize_value(value)
      value.to_s.strip.squeeze(' ')
    end
  end
end
