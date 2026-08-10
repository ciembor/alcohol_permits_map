module Sim
  class PopulationSnapshot
    SOURCE_URL = 'https://msip.krakow.pl/dataset/2282'.freeze

    def self.for_report(report_at)
      new(report_at).as_json
    end

    def initialize(report_at)
      @report_at = report_at
    end

    def as_json
      observed_on = snapshot_date
      return empty_snapshot unless observed_on

      records = SimPopulation.where(observed_on: observed_on).order(:sim_unit_code).to_a
      units_by_code = Sim::Units.by_code
      city_total = records.sum(&:total)
      city_area_km2 = records.sum { |record| units_by_code.fetch(record.sim_unit_code).fetch(:area_km2) }

      {
        observed_on: observed_on.iso8601,
        source: 'MSIP Zameldowania stale',
        source_url: SOURCE_URL,
        unit: 'zameldowani na pobyt staly',
        city: {
          name: 'Krakow',
          total: city_total,
          area_km2: city_area_km2.round(2)
        },
        districts: district_totals(records, units_by_code),
        sim_units: sim_unit_totals(records, units_by_code)
      }
    end

    private

    attr_reader :report_at

    def snapshot_date
      return unless report_at

      SimPopulation
        .where('observed_on <= ?', report_at.to_date)
        .maximum(:observed_on)
    end

    def empty_snapshot
      {
        observed_on: nil,
        source: 'MSIP Zameldowania stale',
        source_url: SOURCE_URL,
        unit: 'zameldowani na pobyt staly',
        city: nil,
        districts: {},
        sim_units: {}
      }
    end

    def district_totals(records, units_by_code)
      records.group_by(&:district_name).each_with_object({}) do |(district_name, district_records), memo|
        memo[district_name] = {
          name: district_name,
          total: district_records.sum(&:total),
          area_km2: district_records.sum { |record| units_by_code.fetch(record.sim_unit_code).fetch(:area_km2) }.round(2)
        }
      end
    end

    def sim_unit_totals(records, units_by_code)
      records.each_with_object({}) do |record, memo|
        unit = units_by_code.fetch(record.sim_unit_code)

        memo[record.sim_unit_code] = {
          code: record.sim_unit_code,
          name: record.sim_unit_name,
          district: record.district_name,
          total: record.total,
          area_km2: unit.fetch(:area_km2).round(2)
        }
      end
    end
  end
end
