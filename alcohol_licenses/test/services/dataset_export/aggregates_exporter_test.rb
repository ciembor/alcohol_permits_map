require 'test_helper'
require 'csv'
require 'tmpdir'

class DatasetExport::AggregatesExporterTest < ActiveSupport::TestCase
  test 'writes city district and sim aggregate rows from public csv tables' do
    Dir.mktmpdir do |dir|
      config = DatasetExport::Config.new(version: 'v-test', output_dir: dir, include_source_files: false, latest_only: true)
      paths = DatasetExport::Paths.new(config)
      paths.mkdirs
      write_input_csvs(paths)

      counts = DatasetExport::Exporters::AggregatesExporter.new(paths: paths).write

      assert_equal 1, counts.fetch(:city_summary_by_report_csv)
      assert_equal Sim::Units.all.map { |unit| unit.fetch(:district) }.uniq.size, counts.fetch(:district_summary_by_report_csv)
      assert_equal Sim::Units.all.size, counts.fetch(:sim_summary_by_report_csv)

      city = CSV.read(paths.city_summary_by_report_csv, headers: true, encoding: 'UTF-8').first
      assert_equal DatasetExport::AggregateRows::COLUMNS, city.headers
      assert_equal 'Krakow', city.fetch('area_code')
      assert_equal '2', city.fetch('license_count')
      assert_equal '2', city.fetch('geocoded_license_count')
      assert_equal '1', city.fetch('point_count')
      assert_equal '1', city.fetch('mixed_point_count')
      assert_equal '1', city.fetch('category_a_license_count')
      assert_equal '1', city.fetch('category_b_license_count')

      sim = CSV.read(paths.sim_summary_by_report_csv, headers: true, encoding: 'UTF-8')
        .find { |row| row.fetch('area_code') == 'I.8' }
      assert_equal 'Kazimierz', sim.fetch('area_name')
      assert_equal '2', sim.fetch('license_count')
      assert_equal '1', sim.fetch('point_count')
      assert_equal '1000', sim.fetch('population_total')
    end
  end

  private

  def write_input_csvs(paths)
    CSV.open(paths.reports_csv, 'w:UTF-8', write_headers: true, headers: %w[report_id reported_at report_date]) do |csv|
      csv << ['report-2026-02-01T00-00-00Z', '2026-02-01T00:00:00Z', '2026-02-01']
    end

    CSV.open(paths.alcohol_licenses_csv, 'w:UTF-8', write_headers: true, headers: %w[reported_at geocoded district_code district_name sim_unit_code business_category license_category]) do |csv|
      csv << ['2026-02-01T00:00:00Z', 'true', 'I', 'Dzielnica I Stare Miasto', 'I.8', 'detal', 'A']
      csv << ['2026-02-01T00:00:00Z', 'true', 'I', 'Dzielnica I Stare Miasto', 'I.8', 'gastronomia', 'B']
    end

    CSV.open(paths.license_points_csv, 'w:UTF-8', write_headers: true, headers: %w[reported_at district_code district_name sim_unit_code retail_flag gastronomy_flag license_count retail_license_count gastronomy_license_count license_count_a license_count_b license_count_c]) do |csv|
      csv << ['2026-02-01T00:00:00Z', 'I', 'Dzielnica I Stare Miasto', 'I.8', 'true', 'true', 2, 1, 1, 1, 1, 0]
    end

    CSV.open(paths.sim_populations_csv, 'w:UTF-8', write_headers: true, headers: %w[observed_on sim_unit_code district_code district_name population_total]) do |csv|
      Sim::Units.all.each do |unit|
        total = unit.fetch(:code) == 'I.8' ? 1000 : 0
        csv << ['2025-12-31', unit.fetch(:code), unit.fetch(:district_code), unit.fetch(:district), total]
      end
    end
  end
end
