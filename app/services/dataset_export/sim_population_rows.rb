require 'sim/population_importer'

module DatasetExport
  class SimPopulationRows
    COLUMNS = %w[
      observed_on
      observed_on_code
      sim_unit_code
      sim_unit_name
      district_code
      district_name
      population_total
      unit
      source
      source_url
    ].freeze

    SOURCE = 'MSIP Krakow Elud SIM'.freeze
    SOURCE_URL = Sim::PopulationImporter::ENDPOINT

    def columns
      COLUMNS
    end

    def each
      return enum_for(:each) unless block_given?

      scope.find_each(batch_size: 1_000) do |population|
        yield({
          'observed_on' => population.observed_on.iso8601,
          'observed_on_code' => population.observed_on_code,
          'sim_unit_code' => population.sim_unit_code,
          'sim_unit_name' => population.sim_unit_name,
          'district_code' => population.district_code,
          'district_name' => population.district_name,
          'population_total' => population.total,
          'unit' => 'registered residents',
          'source' => SOURCE,
          'source_url' => SOURCE_URL
        })
      end
    end

    private

    def scope
      SimPopulation.order(:observed_on, :sim_unit_code)
    end
  end
end
