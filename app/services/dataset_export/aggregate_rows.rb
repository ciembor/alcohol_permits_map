require 'csv'
require 'date'
require 'set'
require 'time'

require_dependency 'sim/units'

module DatasetExport
  class AggregateRows
    COLUMNS = %w[
      report_id
      reported_at
      report_date
      area_type
      area_code
      area_name
      district_code
      district_name
      area_km2
      population_snapshot_date
      population_total
      license_count
      geocoded_license_count
      point_count
      retail_point_count
      gastronomy_point_count
      mixed_point_count
      retail_license_count
      gastronomy_license_count
      category_a_license_count
      category_b_license_count
      category_c_license_count
      points_per_1000_registered_residents
      licenses_per_1000_registered_residents
      points_per_km2
      licenses_per_km2
    ].freeze

    def initialize(paths:)
      @paths = paths
      @units = Sim::Units.all
      @units_by_code = units.index_by { |unit| unit.fetch(:code) }
      @districts = units.group_by { |unit| unit.fetch(:district) }.map do |district_name, district_units|
        {
          code: district_units.first.fetch(:district_code),
          name: district_name,
          area_km2: district_units.sum { |unit| unit.fetch(:area_km2).to_f }.round(4)
        }
      end.sort_by { |district| district.fetch(:code) }
    end

    def city_rows
      reports.map { |report| row_for(report, city_area) }
    end

    def district_rows
      reports.flat_map do |report|
        districts.map { |district| row_for(report, district_area(district)) }
      end
    end

    def sim_rows
      reports.flat_map do |report|
        units.map { |unit| row_for(report, sim_area(unit)) }
      end
    end

    private

    attr_reader :paths, :units, :units_by_code, :districts

    def reports
      @reports ||= CSV.read(paths.reports_csv, headers: true, encoding: 'UTF-8').map do |row|
        {
          report_id: row.fetch('report_id'),
          reported_at: row.fetch('reported_at'),
          report_date: row.fetch('report_date')
        }
      end
    end

    def row_for(report, area)
      metrics = metrics_for(report.fetch(:reported_at), area)
      population = population_for(report.fetch(:reported_at), area)
      area_km2 = area.fetch(:area_km2).to_f
      population_total = population&.fetch(:population_total)

      {
        'report_id' => report.fetch(:report_id),
        'reported_at' => report.fetch(:reported_at),
        'report_date' => report.fetch(:report_date),
        'area_type' => area.fetch(:area_type),
        'area_code' => area.fetch(:area_code),
        'area_name' => area.fetch(:area_name),
        'district_code' => area.fetch(:district_code),
        'district_name' => area.fetch(:district_name),
        'area_km2' => area_km2,
        'population_snapshot_date' => population&.fetch(:observed_on),
        'population_total' => population_total,
        'license_count' => metrics.fetch(:license_count),
        'geocoded_license_count' => metrics.fetch(:geocoded_license_count),
        'point_count' => metrics.fetch(:point_count),
        'retail_point_count' => metrics.fetch(:retail_point_count),
        'gastronomy_point_count' => metrics.fetch(:gastronomy_point_count),
        'mixed_point_count' => metrics.fetch(:mixed_point_count),
        'retail_license_count' => metrics.fetch(:retail_license_count),
        'gastronomy_license_count' => metrics.fetch(:gastronomy_license_count),
        'category_a_license_count' => metrics.fetch(:category_a_license_count),
        'category_b_license_count' => metrics.fetch(:category_b_license_count),
        'category_c_license_count' => metrics.fetch(:category_c_license_count),
        'points_per_1000_registered_residents' => rate(metrics.fetch(:point_count), population_total, 1_000.0),
        'licenses_per_1000_registered_residents' => rate(metrics.fetch(:license_count), population_total, 1_000.0),
        'points_per_km2' => rate(metrics.fetch(:point_count), area_km2, 1.0),
        'licenses_per_km2' => rate(metrics.fetch(:license_count), area_km2, 1.0)
      }
    end

    def metrics_for(reported_at, area)
      base_metrics.merge(license_metrics.fetch([reported_at, area.fetch(:area_type), area.fetch(:area_code)], empty_license_metrics))
        .merge(point_metrics.fetch([reported_at, area.fetch(:area_type), area.fetch(:area_code)], empty_point_metrics))
    end

    def license_metrics
      @license_metrics ||= build_license_metrics
    end

    def point_metrics
      @point_metrics ||= build_point_metrics
    end

    def build_license_metrics
      metrics = Hash.new { |hash, key| hash[key] = empty_license_metrics.dup }

      CSV.foreach(paths.alcohol_licenses_csv, headers: true, encoding: 'UTF-8') do |row|
        metric = metrics[[row.fetch('reported_at'), 'city', 'Krakow']]
        metric[:license_count] += 1
        metric[:geocoded_license_count] += 1 if row.fetch('geocoded') == 'true'
        metric[:retail_license_count] += 1 if row.fetch('business_category') == 'detal'
        metric[:gastronomy_license_count] += 1 if row.fetch('business_category') == 'gastronomia'
        case row.fetch('license_category')
        when 'A' then metric[:category_a_license_count] += 1
        when 'B' then metric[:category_b_license_count] += 1
        when 'C' then metric[:category_c_license_count] += 1
        end
      end

      metrics
    end

    def build_point_metrics
      metrics = Hash.new { |hash, key| hash[key] = empty_point_metrics.dup }

      CSV.foreach(paths.license_points_csv, headers: true, encoding: 'UTF-8') do |row|
        area_keys_for_point(row).each do |key|
          metric = metrics[key]
          metric[:point_count] += 1
          retail = row.fetch('retail_flag') == 'true'
          gastronomy = row.fetch('gastronomy_flag') == 'true'
          if retail && gastronomy
            metric[:mixed_point_count] += 1
          elsif retail
            metric[:retail_point_count] += 1
          elsif gastronomy
            metric[:gastronomy_point_count] += 1
          end
          add_point_license_metrics(metric, row) unless key[1] == 'city'
        end
      end

      metrics
    end

    def area_keys_for_point(row)
      reported_at = row.fetch('reported_at')
      keys = [[reported_at, 'city', 'Krakow']]
      district_code = row.fetch('district_code')
      sim_unit_code = row.fetch('sim_unit_code')
      keys << [reported_at, 'district', district_code] if district_code.present?
      keys << [reported_at, 'sim_unit', sim_unit_code] if sim_unit_code.present?
      keys
    end

    def add_point_license_metrics(metric, row)
      license_count = row.fetch('license_count').to_i
      metric[:license_count] = metric.fetch(:license_count, 0) + license_count
      metric[:geocoded_license_count] = metric.fetch(:geocoded_license_count, 0) + license_count
      metric[:retail_license_count] = metric.fetch(:retail_license_count, 0) + row.fetch('retail_license_count').to_i
      metric[:gastronomy_license_count] = metric.fetch(:gastronomy_license_count, 0) + row.fetch('gastronomy_license_count').to_i
      metric[:category_a_license_count] = metric.fetch(:category_a_license_count, 0) + row.fetch('license_count_a').to_i
      metric[:category_b_license_count] = metric.fetch(:category_b_license_count, 0) + row.fetch('license_count_b').to_i
      metric[:category_c_license_count] = metric.fetch(:category_c_license_count, 0) + row.fetch('license_count_c').to_i
    end

    def population_for(reported_at, area)
      observed_on = population_snapshot_date(reported_at)
      return unless observed_on

      population_metrics.fetch([observed_on, area.fetch(:area_type), area.fetch(:area_code)], nil)
    end

    def population_metrics
      @population_metrics ||= build_population_metrics
    end

    def build_population_metrics
      metrics = {}

      CSV.foreach(paths.sim_populations_csv, headers: true, encoding: 'UTF-8') do |row|
        observed_on = row.fetch('observed_on')
        total = row.fetch('population_total').to_i
        sim_code = row.fetch('sim_unit_code')
        district_code = row.fetch('district_code')

        metrics[[observed_on, 'sim_unit', sim_code]] = {
          observed_on: observed_on,
          population_total: total
        }
        add_population(metrics, [observed_on, 'district', district_code], total)
        add_population(metrics, [observed_on, 'city', 'Krakow'], total)
      end

      metrics
    end

    def add_population(metrics, key, total)
      metrics[key] ||= { observed_on: key.first, population_total: 0 }
      metrics[key][:population_total] += total
    end

    def population_snapshot_date(reported_at)
      date = Time.parse(reported_at).to_date
      population_dates.select { |observed_on| Date.iso8601(observed_on) <= date }.max
    end

    def population_dates
      @population_dates ||= CSV.foreach(paths.sim_populations_csv, headers: true, encoding: 'UTF-8').map { |row| row.fetch('observed_on') }.uniq.sort
    end

    def city_area
      {
        area_type: 'city',
        area_code: 'Krakow',
        area_name: 'Krakow',
        district_code: nil,
        district_name: nil,
        area_km2: units.sum { |unit| unit.fetch(:area_km2).to_f }.round(4)
      }
    end

    def district_area(district)
      {
        area_type: 'district',
        area_code: district.fetch(:code),
        area_name: district.fetch(:name),
        district_code: district.fetch(:code),
        district_name: district.fetch(:name),
        area_km2: district.fetch(:area_km2)
      }
    end

    def sim_area(unit)
      {
        area_type: 'sim_unit',
        area_code: unit.fetch(:code),
        area_name: unit.fetch(:name),
        district_code: unit.fetch(:district_code),
        district_name: unit.fetch(:district),
        area_km2: unit.fetch(:area_km2).to_f
      }
    end

    def base_metrics
      empty_license_metrics.merge(empty_point_metrics)
    end

    def empty_license_metrics
      {
        license_count: 0,
        geocoded_license_count: 0,
        retail_license_count: 0,
        gastronomy_license_count: 0,
        category_a_license_count: 0,
        category_b_license_count: 0,
        category_c_license_count: 0
      }
    end

    def empty_point_metrics
      {
        point_count: 0,
        retail_point_count: 0,
        gastronomy_point_count: 0,
        mixed_point_count: 0
      }
    end

    def rate(count, denominator, multiplier)
      return if denominator.blank?

      value = denominator.to_f
      return if value <= 0

      (count.to_f * multiplier / value).round(2)
    end
  end
end
