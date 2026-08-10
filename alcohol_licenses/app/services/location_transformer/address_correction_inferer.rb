require 'location_transformer/address_1_transformer'
require 'location_transformer/address_2_transformer'
require 'location_transformer/transformer'

module LocationTransformer
  class AddressCorrectionInferer
    SOURCE = 'internal_history'.freeze
    METHOD = 'same_business_same_normalized_street'.freeze
    CONFIDENCE = 0.85

    def initialize
      transformer = LocationTransformer::Transformer.new
      @address_1_transformer = transformer.send(:address_1_transformer)
      @address_2_transformer = transformer.send(:address_2_transformer)
    end

    def infer_all
      Location.where(address_2: nil).filter_map { |location| infer(location) }
    end

    def infer(location)
      candidates = correction_candidates(location)
      return unless candidates.size == 1

      candidate = candidates.values.first
      create_correction(location, candidate)
    end

    private

    attr_reader :address_1_transformer, :address_2_transformer

    def correction_candidates(location)
      candidates = {}
      target_address_1 = normalize_address_1(location.address_1)

      location.alcohol_licenses.each do |license|
        AlcoholLicense
          .joins(:location)
          .where(business_id: license.business_id)
          .where.not(locations: { id: location.id })
          .where.not(locations: { address_2: nil })
          .pluck('locations.id', 'locations.address_1', 'locations.address_2')
          .each do |source_location_id, address_1, address_2|
            next unless normalize_address_1(address_1) == target_address_1

            parsed_address_2 = address_2_transformer.transform(address_2)
            next unless usable_candidate?(parsed_address_2)

            key = [
              parsed_address_2[:address_kind],
              parsed_address_2[:address_relation],
              parsed_address_2[:building_number],
              parsed_address_2[:unit_number],
              parsed_address_2[:parcel_number],
              parsed_address_2[:parcel_region],
              parsed_address_2[:parcel_cadastral_unit]
            ]
            candidates[key] ||= {
              corrected_address_1: address_1,
              corrected_address_2: address_2,
              source_location_id: source_location_id,
              parsed_address_2: parsed_address_2,
              occurrences: 0
            }
            candidates[key][:occurrences] += 1
          end
      end

      candidates
    end

    def normalize_address_1(address_1)
      address_1_transformer.transform_address_1(address_1) || address_1
    end

    def usable_candidate?(parsed_address_2)
      return false if parsed_address_2[:building_number] == '0'

      parsed_address_2[:building_number].present? ||
        parsed_address_2[:parcel_number].present? ||
        parsed_address_2[:unit_number].present?
    end

    def create_correction(location, candidate)
      AddressCorrection.find_or_create_by!(
        location: location,
        source: SOURCE,
        method: METHOD,
        corrected_address_1: candidate[:corrected_address_1],
        corrected_address_2: candidate[:corrected_address_2]
      ) do |correction|
        correction.source_location_id = candidate[:source_location_id]
        correction.confidence = CONFIDENCE
        correction.selected = true
        correction.evidence = evidence(candidate)
      end
    end

    def evidence(candidate)
      [
        "Inferred from #{candidate[:occurrences]} historical record(s)",
        "source_location_id=#{candidate[:source_location_id]}"
      ].join('; ')
    end
  end
end
