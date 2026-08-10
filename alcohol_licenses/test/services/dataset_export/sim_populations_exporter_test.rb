require 'test_helper'
require 'csv'
require 'tmpdir'

class DatasetExport::SimPopulationsExporterTest < ActiveSupport::TestCase
  setup do
    SimPopulation.delete_all
    seed_sim_population_records
  end

  teardown do
    SimPopulation.delete_all
  end

  test 'writes sim population rows with source metadata' do
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'sim_populations.csv')
      count = DatasetExport::Exporters::SimPopulationsExporter.new(path: path).write

      assert_equal 2, count

      csv = CSV.read(path, headers: true, encoding: 'UTF-8')
      assert_equal DatasetExport::SimPopulationRows::COLUMNS, csv.headers
      assert_equal ['2025-12-31'], csv.map { |row| row.fetch('observed_on') }.uniq
      assert_equal ['registered residents'], csv.map { |row| row.fetch('unit') }.uniq
      assert_equal [DatasetExport::SimPopulationRows::SOURCE], csv.map { |row| row.fetch('source') }.uniq
      assert_equal [DatasetExport::SimPopulationRows::SOURCE_URL], csv.map { |row| row.fetch('source_url') }.uniq
    end
  end

  private

  def seed_sim_population_records
    SimPopulation.create!(
      observed_on: Date.new(2025, 12, 31),
      observed_on_code: 20251231,
      sim_unit_code: 'I.1',
      sim_unit_name: 'Stare Miasto',
      district_code: 'I',
      district_name: 'Dzielnica I Stare Miasto',
      total: 100
    )
    SimPopulation.create!(
      observed_on: Date.new(2025, 12, 31),
      observed_on_code: 20251231,
      sim_unit_code: 'I.2',
      sim_unit_name: 'Kazimierz',
      district_code: 'I',
      district_name: 'Dzielnica I Stare Miasto',
      total: 200
    )
  end
end
