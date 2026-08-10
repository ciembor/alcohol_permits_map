module Geocoding
  class LocationUncertainty
    PRECISE_GOOGLE_TYPES = %w[
      establishment
      point_of_interest
      premise
      street_address
      subpremise
    ].freeze

    IMPRECISE_PRECISION_PATTERN = %r{(^derived/|/road\z|/neighbourhood\z|/quarter\z|/junction\z)}

    def self.reasons(location)
      new(location).reasons
    end

    def initialize(location)
      @location = location
    end

    def reasons
      reasons = []
      reasons.concat(geocoding_reasons)
      reasons << 'działka bez jednoznacznego dopasowania w ewidencji' if uncertain_parcel?
      reasons << "mało precyzyjny wynik geokodowania: #{precision}" if imprecise_precision?
      reasons.uniq.sort
    end

    private

    attr_reader :location

    def geocoding_reasons
      return ['brak potwierdzonego wyniku geokodowania'] if strategy.blank?
      return [] if precise_google_result?

      reasons = []
      reasons << "mało precyzyjny wynik geokodowania Google: #{precision}" if source == 'google'
      reasons << "wynik z przybliżonej strategii: #{strategy}" unless strategy == 'address_point' || strategy == 'cadastral_parcel'
      reasons
    end

    def uncertain_parcel?
      return false if precise_google_result?

      address_kind == 'parcel' && !(strategy == 'cadastral_parcel' && precision.start_with?('parcel/'))
    end

    def imprecise_precision?
      return false if precise_google_result?

      precision.match?(IMPRECISE_PRECISION_PATTERN)
    end

    def precise_google_result?
      source == 'google' &&
        precision.start_with?('ROOFTOP/') &&
        (precision.split('/')[1].to_s.split('|') & PRECISE_GOOGLE_TYPES).any?
    end

    def source
      value(:geocoding_source).to_s
    end

    def strategy
      value(:geocoding_strategy).to_s
    end

    def precision
      value(:geocoding_precision).to_s
    end

    def address_kind
      value(:address_kind).to_s
    end

    def value(key)
      if location.respond_to?(key)
        location.public_send(key)
      elsif location.respond_to?(:[])
        location[key] || location[key.to_s]
      end
    end
  end
end
