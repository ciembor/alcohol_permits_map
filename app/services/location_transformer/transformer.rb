require 'location_transformer/address_1_transformer'
require 'location_transformer/address_2_transformer'

module LocationTransformer
  class Transformer
    ABBREVIATIONS = [
      ['Świętego', 'Świętej', 'Św.', 'Św'],
      ['Księdza', 'Ks.', 'Ks'],
      ['Pułkownika', 'Płk.', 'Płk'],
      ['Doktora', 'Doktor', 'Dr.', 'Dr'],
      ['Profesora', 'Profesor', 'Prof.', 'Prof'],
      ['Osiedle', 'Os.', 'Os', 'Oś.', 'Oś'],
      ['Generała', 'Gen.', 'Gen'],
      ['Biskupa', 'Bp.', 'Bp'],
      ['Arcybiskupa', 'Abp.', 'Abp'],
      ['Insp.'],
      ['Pil.'],
      ['Ulica', 'Ul.', 'Ul'],
      ['Aleja', 'Al.', 'Al'],
      ['Plac', 'Pl.', 'Pl'],
    ].freeze

    PARCEL_CADASTRAL_UNIT_BY_STREET = [
      [/plac inwalid/i, 'krowodrza']
    ].freeze

    def initialize
      streets = Street.pluck(:name_1, :name_2)

      @address_1_transformer = LocationTransformer::Address1Transformer.new(
        not_unique_words: not_unique_words(streets),
        abbreviations: ABBREVIATIONS,
        streets: streets
      )
      @address_2_transformer = LocationTransformer::Address2Transformer.new
    end

    def transform_locations
      Location.all.each do |location|
        original_address_1 = location.address_1
        original_address_2 = location.address_2
        parsed_address = parse_address_parts(location)
        address_1 = address_1_transformer.transform_address_1(parsed_address[:address_1])
        same_as = address_1_transformer.same_as_for(parsed_address[:address_1])
        address_2 = address_2_transformer.transform(parsed_address[:address_2])

        log(original_address_1, original_address_2, address_1, address_2)

        find_or_create_transformed_location(location, address_1 || parsed_address[:address_1], address_2, same_as)
      end
    end

    private

    attr_accessor :address_1_transformer, :address_2_transformer

    def not_unique_words(streets)
      streets
        .flatten
        .compact
        .flat_map { |word| word.split(' ') }
        .tally
        .select { |_word, count| count > 1 }
        .map { |word, _count| word.upcase }
    end

    def parse_address_parts(location_or_address_1, address_2 = nil)
      if location_or_address_1.respond_to?(:selected_address_correction)
        location = location_or_address_1
        correction = location.selected_address_correction
        return correction.address_parts if correction

        address_1 = location.address_1
        address_2 = location.address_2
      else
        address_1 = location_or_address_1
      end

      split_address_2 = split_street_from_address_2(address_1, address_2)
      return split_address_2 if split_address_2

      return { address_1: address_1, address_2: address_2 } if address_2.present?

      split_address_1 = split_embedded_address(address_1)
      split_address_1 || { address_1: address_1, address_2: address_2 }
    end

    def split_street_from_address_2(address_1, address_2)
      return if address_1.blank? || address_2.blank?

      normalized_address_2 = address_2.to_s.strip.squeeze(' ')
      match = normalized_address_2.match(/\A(.+?)\s+(\d+[[:alpha:]]?(?:\b|\/).*)\z/i)
      return unless match
      return if numeric_street_candidate?(match[1])

      candidate_street = address_1_transformer.transform_address_1(match[1])
      return unless candidate_street

      { address_1: candidate_street, address_2: match[2] }
    end

    def numeric_street_candidate?(candidate)
      candidate.to_s.strip.match?(/\A\d+[[:alpha:]]?\s*(?:[\/.,;-]|\z)/i)
    end

    def split_embedded_address(address_1)
      normalized_address = address_1.to_s.strip.squeeze(' ')
      return if normalized_address.blank?

      words = normalized_address.split
      words.each_with_index do |word, index|
        next unless word.match?(/\A\d+[[:alpha:]]?(?:\/.*)?\z/i)
        next if index.zero?

        street_part = words[0...index].join(' ')
        address_2_part = words[index..].join(' ')
        next unless address_1_transformer.transform_address_1(street_part)

        return { address_1: street_part, address_2: address_2_part }
      end

      nil
    end

    def find_or_create_transformed_location(location, address_1, address_2, same_as = nil)
      geocoding_identity = {
        address_1: address_1,
        building_number: address_2[:building_number],
        address_kind: address_2[:address_kind],
        address_relation: address_2[:address_relation],
        unit_number: address_2[:unit_number],
        parcel_number: address_2[:parcel_number],
        parcel_region: address_2[:parcel_region],
        parcel_cadastral_unit: address_2[:parcel_cadastral_unit]
      }

      geocoding_identity[:parcel_cadastral_unit] ||= inferred_parcel_cadastral_unit(address_1, address_2)

      transformed_location = TransformedLocation.find_or_initialize_by(geocoding_identity)
      transformed_location.raw_address_2 = address_2[:raw_address_2]
      transformed_location.same_as = merged_same_as(transformed_location.same_as, same_as)
      transformed_location.save!

      location.update!(
        transformed_location: transformed_location
      )

      sync_raw_address_2(transformed_location, address_2[:raw_address_2])
    end

    def inferred_parcel_cadastral_unit(address_1, address_2)
      return unless address_2[:address_kind] == 'parcel'

      PARCEL_CADASTRAL_UNIT_BY_STREET.each do |street_pattern, cadastral_unit|
        return cadastral_unit if address_1.to_s.match?(street_pattern)
      end

      nil
    end

    def merged_same_as(existing_value, new_value)
      values = existing_value.to_s.split('|').map(&:strip)
      values << new_value.to_s.strip if new_value.present?
      values.reject(&:blank?).uniq.join('|').presence
    end

    def sync_raw_address_2(transformed_location, current_raw_address_2)
      raw_address_2 = current_raw_address_2.presence || transformed_location.locations.reload.filter_map do |linked_location|
        linked_location.address_2.to_s.strip.squeeze(' ').presence
      end.first

      transformed_location.update!(raw_address_2: raw_address_2)
    end

    def log(original_address_1, original_address_2, address_1, address_2)
      puts "transformed #{original_address_1} with address #{original_address_2} >>> #{address_1} with #{address_2}"
    end
  end
end
