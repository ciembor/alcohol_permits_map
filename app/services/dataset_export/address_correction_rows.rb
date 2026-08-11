require 'dataset_export/stable_id'

module DatasetExport
  class AddressCorrectionRows
    COLUMNS = %w[
      correction_id
      raw_location_id
      source_raw_location_id
      corrected_address_1
      corrected_address_2
      source
      method
      confidence
      selected
      evidence
    ].freeze

    def initialize(latest_only: false)
      @latest_only = latest_only
      @latest_reported_at = AlcoholLicense.maximum(:reported_at) if latest_only
    end

    def columns
      COLUMNS
    end

    def each
      return enum_for(:each) unless block_given?

      scope.find_each(batch_size: 500) do |correction|
        raw_location_id = raw_location_id_for(correction.location)
        source_raw_location_id = correction.source_location ? raw_location_id_for(correction.source_location) : nil

        yield({
          'correction_id' => DatasetExport::StableId.address_correction_id(
            raw_location_id: raw_location_id,
            source_raw_location_id: source_raw_location_id,
            corrected_address_1: correction.corrected_address_1,
            corrected_address_2: correction.corrected_address_2,
            source: correction.source,
            method: correction.method
          ),
          'raw_location_id' => raw_location_id,
          'source_raw_location_id' => source_raw_location_id,
          'corrected_address_1' => correction.corrected_address_1,
          'corrected_address_2' => correction.corrected_address_2,
          'source' => correction.source,
          'method' => correction.method,
          'confidence' => correction.confidence,
          'selected' => correction.selected,
          'evidence' => correction.evidence
        })
      end
    end

    private

    attr_reader :latest_only, :latest_reported_at

    def scope
      relation = AddressCorrection.includes(:location, :source_location).order(:id)
      return relation unless latest_only

      latest_location_ids = AlcoholLicense.where(reported_at: latest_reported_at).distinct.pluck(:location_id)
      relation.where(location_id: latest_location_ids).where(source_location_id: [nil, *latest_location_ids])
    end

    def raw_location_id_for(location)
      DatasetExport::StableId.raw_location_id(
        source_address_1: location.address_1,
        source_address_2: location.address_2
      )
    end
  end
end
