require 'geocoding/location_uncertainty'

class MapsController < ApplicationController
  def index
    @reports = available_reports
    @initial_report = @reports.last
  end

  def licenses
    report_at = requested_report || available_reports.last
    points = report_at ? license_points(report_at) : []

    render json: {
      year: report_at&.year,
      report_at: report_at,
      summary: report_at ? report_summary(report_at) : empty_summary,
      population: report_at ? population_snapshot(report_at) : empty_population_snapshot,
      sim_areas: report_at ? sim_areas(points) : [],
      points: points
    }
  end

  def raw_records
    report_at = requested_report || available_reports.last
    point_id = params[:point_id].to_i

    render json: {
      report_at: report_at,
      point_id: point_id,
      raw_records: report_at && point_id.positive? ? raw_records_for_point(report_at, point_id) : []
    }
  end

  def statistics
    sim_locator = Sim::Locator.new
    business_categories = selected_filter_values(:business_categories, BusinessCategory.order(:name).pluck(:name))
    license_categories = selected_filter_values(:license_categories, LicenseCategory.order(:name).pluck(:name))
    sim_unit = params[:sim_unit].presence
    sim_area_code = params[:sim_area_code].presence
    metric = params[:metric].presence || 'premises'

    render json: {
      filters: {
        business_categories: business_categories,
        license_categories: license_categories,
        sim_unit: sim_unit,
        sim_area_code: sim_area_code,
        metric: metric
      },
      reports: statistics_reports(
        business_categories: business_categories,
        license_categories: license_categories,
        sim_unit: sim_unit,
        sim_area_code: sim_area_code,
        sim_locator: sim_locator,
        metric: metric
      )
    }
  end

  def statistics_static
    path = Rails.root.join('storage/prod_alkomapa_data_local/data/statistics.json')
    return head :not_found unless File.exist?(path)

    send_file path, type: 'application/json', disposition: 'inline'
  end

  private

  def requested_report
    return unless params[:report_at].present?

    AlcoholLicense
      .where(reported_at: Time.zone.parse(params[:report_at]).utc)
      .pick(:reported_at)
  rescue ArgumentError, TypeError
    nil
  end

  def available_reports
    AlcoholLicense
      .where.not(reported_at: nil)
      .distinct
      .order(:reported_at)
      .pluck(:reported_at)
  end

  def available_years
    AlcoholLicense
      .where.not(reported_at: nil)
      .distinct
      .pluck(:reported_at)
      .map(&:year)
      .uniq
      .sort
  end

  def report_for_year(year)
    AlcoholLicense
      .where(reported_at: Time.utc(year).all_year)
      .maximum(:reported_at)
  end

  def license_points(report_at, sim_locator: Sim::Locator.new)
    licenses = AlcoholLicense
      .left_joins(:license_point_group)
      .joins(:business, :business_category, :license_category, location: :transformed_location)
      .joins(<<~SQL.squish)
        LEFT JOIN geocoding_results selected_geocoding_results
          ON selected_geocoding_results.transformed_location_id = transformed_locations.id
          AND selected_geocoding_results.selected = 1
      SQL
      .where(reported_at: report_at)
      .where.not(transformed_locations: { latitude: nil, longtitude: nil })
      .select(
        'alcohol_licenses.id',
        'alcohol_licenses.reported_at',
        'alcohol_licenses.expires_at',
        'alcohol_licenses.license_point_group_id',
        'license_point_groups.display_business_name AS group_display_business_name',
        'license_point_groups.normalized_business_name AS group_normalized_business_name',
        'license_point_groups.similarity_floor AS group_similarity_floor',
        'businesses.id AS business_id',
        'businesses.name AS business_name',
        'business_categories.name AS business_category_name',
        'license_categories.name AS license_category_name',
        'license_categories.description AS license_category_description',
        'locations.address_1 AS source_address_1',
        'locations.address_2 AS source_address_2',
        'transformed_locations.address_1 AS address_1',
        'transformed_locations.building_number AS building_number',
        'transformed_locations.address_kind AS address_kind',
        'transformed_locations.parcel_number AS parcel_number',
        'transformed_locations.latitude AS latitude',
        'transformed_locations.longtitude AS longitude',
        'transformed_locations.osm_latitude AS osm_latitude',
        'transformed_locations.osm_longitude AS osm_longitude',
        'transformed_locations.osm_geocoding_strategy AS osm_geocoding_strategy',
        'transformed_locations.osm_geocoding_precision AS osm_geocoding_precision',
        'transformed_locations.osm_geocoding_query AS osm_geocoding_query',
        'selected_geocoding_results.source AS geocoding_source',
        'selected_geocoding_results.strategy AS geocoding_strategy',
        'selected_geocoding_results.precision AS geocoding_precision'
      )

    licenses.group_by do |license|
      [license.latitude, license.longitude, license.license_point_group_id || "business:#{license.business_id}"]
    end.map do |(latitude, longitude, group_key), grouped_licenses|
      categories = grouped_licenses.map(&:license_category_name).uniq.sort
      license_counts_by_category = grouped_licenses.group_by(&:license_category_name).transform_values(&:size)
      business_categories = grouped_licenses.map(&:business_category_name).uniq.sort
      license_counts_by_business_category = grouped_licenses.group_by(&:business_category_name).transform_values(&:size)
      businesses = grouped_licenses.map(&:business_name).uniq.sort
      business_ids = grouped_licenses.map(&:business_id).uniq.sort
      business_license_details = business_license_details(grouped_licenses)
      addresses = grouped_licenses.map { |license| display_address(license) }.uniq
      sim = sim_locator.locate(latitude, longitude)
      point_group_id = grouped_licenses.first.license_point_group_id
      location_uncertainty_reasons = location_uncertainty_reasons(grouped_licenses)

      {
        id: grouped_licenses.map(&:id).min,
        point_group_id: point_group_id,
        group_key: group_key,
        business_id: business_ids.first,
        business_ids: business_ids,
        lat: latitude,
        lng: longitude,
        osm_lat: grouped_licenses.first.osm_latitude,
        osm_lng: grouped_licenses.first.osm_longitude,
        osm_geocoding_strategy: grouped_licenses.first.osm_geocoding_strategy,
        osm_geocoding_precision: grouped_licenses.first.osm_geocoding_precision,
        osm_geocoding_query: grouped_licenses.first.osm_geocoding_query,
        business: grouped_licenses.first.group_display_business_name.presence || businesses.first,
        businesses: businesses,
        business_count: businesses.size,
        business_id_count: business_ids.size,
        business_license_details: business_license_details,
        raw_records_count: grouped_licenses.size,
        normalized_business_name: grouped_licenses.first.group_normalized_business_name,
        business_similarity_floor: grouped_licenses.first.group_similarity_floor,
        business_category: business_categories.first,
        business_categories: business_categories,
        license_counts_by_business_category: license_counts_by_business_category,
        license_category: categories.first,
        license_categories: categories,
        license_counts_by_category: license_counts_by_category,
        license_count: grouped_licenses.size,
        address: addresses.first,
        location_uncertain: location_uncertainty_reasons.any?,
        location_uncertainty_reasons: location_uncertainty_reasons,
        sim_unit: sim&.fetch(:district),
        sim_units: [sim&.fetch(:district)].compact,
        sim_area: sim&.fetch(:name),
        sim_areas: [sim&.fetch(:name)].compact,
        sim_area_code: sim&.fetch(:code),
        expires_at: grouped_licenses.map(&:expires_at).compact.max&.to_date
      }
    end
  end

  def location_uncertainty_reasons(grouped_licenses)
    grouped_licenses.flat_map do |license|
      Geocoding::LocationUncertainty.reasons(license)
    end.uniq.sort
  end

  def business_license_details(grouped_licenses)
    grouped_licenses
      .group_by(&:business_id)
      .map do |business_id, business_licenses|
        license_counts_by_category = business_licenses.group_by(&:license_category_name).transform_values(&:size)
        category_details = business_licenses
          .group_by(&:business_category_name)
          .map do |business_category, category_licenses|
            category_counts = category_licenses.group_by(&:license_category_name).transform_values(&:size)

            {
              business_category: business_category,
              license_count: category_licenses.size,
              license_categories: category_counts.keys.sort,
              license_counts_by_category: category_counts
            }
          end
          .sort_by { |detail| detail.fetch(:business_category).to_s }

        {
          business_id: business_id,
          business: business_licenses.first.business_name,
          business_categories: business_licenses.map(&:business_category_name).uniq.sort,
          license_categories: license_counts_by_category.keys.sort,
          license_counts_by_category: license_counts_by_category,
          license_count: business_licenses.size,
          category_details: category_details
        }
      end
      .sort_by { |detail| detail.fetch(:business).to_s }
  end

  def serialize_raw_records(grouped_licenses)
    grouped_licenses
      .sort_by { |license| [license.business_name.to_s, license.business_category_name.to_s, license.license_category_name.to_s, license.id.to_i] }
      .map do |license|
        {
          id: license.id,
          reported_at: license.reported_at&.to_date,
          expires_at: license.expires_at&.to_date,
          address_1: license.source_address_1,
          address_2: license.source_address_2,
          business: license.business_name,
          business_category: license.business_category_name,
          license_category: license.license_category_name,
          license_category_description: license.license_category_description
        }
      end
  end

  def raw_records_for_point(report_at, point_id)
    base = AlcoholLicense.find_by(id: point_id, reported_at: report_at)
    return [] unless base

    scope = AlcoholLicense
      .joins(:business, :business_category, :license_category, :location)
      .where(reported_at: report_at)

    scope = if base.license_point_group_id.present?
      scope.where(license_point_group_id: base.license_point_group_id)
    else
      scope.where(business_id: base.business_id, location_id: base.location_id)
    end

    serialize_raw_records(
      scope.select(
        'alcohol_licenses.id',
        'alcohol_licenses.reported_at',
        'alcohol_licenses.expires_at',
        'businesses.name AS business_name',
        'business_categories.name AS business_category_name',
        'license_categories.name AS license_category_name',
        'license_categories.description AS license_category_description',
        'locations.address_1 AS source_address_1',
        'locations.address_2 AS source_address_2'
      )
    )
  end

  def report_summary(report_at)
    scope = AlcoholLicense.where(reported_at: report_at)
    geocoded_scope = scope
      .joins(location: :transformed_location)
      .where.not(transformed_locations: { latitude: nil, longtitude: nil })

    total = scope.count
    geocoded = geocoded_scope.count

    {
      total: total,
      geocoded: geocoded,
      geocoded_percent: total.positive? ? (geocoded * 100.0 / total).round(1) : 0,
      by_business_category: BusinessCategory.order(:name).map do |category|
        category_scope = scope.where(business_category: category)
        category_total = category_scope.count
        category_geocoded = geocoded_scope.where(business_category: category).count

        {
          name: category.name,
          total: category_total,
          geocoded: category_geocoded,
          geocoded_percent: category_total.positive? ? (category_geocoded * 100.0 / category_total).round(1) : 0
        }
      end,
      by_license_category: LicenseCategory.order(:name).map do |category|
        category_total = scope.where(license_category: category).count

        {
          name: category.name,
          total: category_total,
          percent: total.positive? ? (category_total * 100.0 / total).round(1) : 0
        }
      end
    }
  end

  def empty_summary
    {
      total: 0,
      geocoded: 0,
      geocoded_percent: 0,
      by_business_category: [],
      by_license_category: []
    }
  end

  def population_snapshot(report_at)
    Sim::PopulationSnapshot.for_report(report_at)
  end

  def empty_population_snapshot
    {
      observed_on: nil,
      source: 'MSIP Zameldowania stale',
      source_url: Sim::PopulationSnapshot::SOURCE_URL,
      unit: 'zameldowani na pobyt staly',
      city: nil,
      districts: {},
      sim_units: {}
    }
  end

  def sim_areas(points)
    counts = points.each_with_object(Hash.new(0)) do |point, memo|
      code = point.fetch(:sim_area_code, nil)
      memo[code] += 1 if code.present?
    end

    Sim::Units.all.map do |unit|
      area_km2 = unit.fetch(:area_km2).to_f
      premises = counts[unit.fetch(:code)]

      {
        code: unit.fetch(:code),
        name: unit.fetch(:name),
        district: unit.fetch(:district),
        area_km2: area_km2,
        premises: premises,
        premises_per_km2: area_km2.positive? ? (premises / area_km2).round(2) : 0,
        geometry: unit.fetch(:geometry)
      }
    end
  end

  def selected_filter_values(key, defaults)
    values = Array(params[key]).flat_map { |value| value.to_s.split(',') }.map(&:strip).reject(&:blank?)
    return values if params["#{key}_selected"].present?

    values.presence || defaults
  end

  def statistics_reports(business_categories:, license_categories:, sim_unit:, sim_area_code:, sim_locator:, metric: 'premises')
    reports = available_reports
    grouped_premises = grouped_statistic_premises(
      business_categories: business_categories,
      license_categories: license_categories,
      sim_unit: sim_unit,
      sim_area_code: sim_area_code,
      sim_locator: sim_locator
    )

    reports.map do |report_at|
      report_groups = grouped_premises.fetch(report_at, {}).values
      premises = premise_counts(report_groups)
      licenses = license_counts(report_groups)
      population = selected_population(population_snapshot(report_at), sim_unit, sim_area_code)

      {
        report_at: report_at.iso8601,
        date: report_at.to_date.iso8601,
        population: population,
        value: statistic_metric_value(metric, premises, licenses, population)
      }
    end
  end

  def statistic_metric_value(metric, premises, licenses, population)
    counts = metric.to_s.start_with?('licenses') ? licenses : premises
    count = counts.fetch(:total)
    return count unless metric.to_s.include?('_per_')
    return unless population

    denominator = metric.to_s.end_with?('_per_1000') ? population.fetch(:total).to_f : population.fetch(:area_km2).to_f
    multiplier = metric.to_s.end_with?('_per_1000') ? 1_000.0 : 1.0
    denominator.positive? ? (count * multiplier / denominator).round(2) : nil
  end

  def grouped_statistic_premises(business_categories:, license_categories:, sim_unit:, sim_area_code:, sim_locator:)
    return {} if business_categories.empty? || license_categories.empty?

    groups = Hash.new { |hash, report_at| hash[report_at] = {} }
    AlcoholLicense
      .joins(:business_category, :license_category, location: :transformed_location)
      .where(business_categories: { name: business_categories }, license_categories: { name: license_categories })
      .where.not(transformed_locations: { latitude: nil, longtitude: nil })
      .select(
        'alcohol_licenses.reported_at',
        "CASE WHEN alcohol_licenses.license_point_group_id IS NULL THEN 'business:' || alcohol_licenses.business_id ELSE 'group:' || alcohol_licenses.license_point_group_id END AS statistic_point_key",
        'business_categories.name AS business_category_name',
        'COUNT(*) AS licenses_count',
        'transformed_locations.latitude AS latitude',
        'transformed_locations.longtitude AS longitude'
      )
      .group(
        'alcohol_licenses.reported_at',
        'statistic_point_key',
        'business_categories.name',
        'transformed_locations.latitude',
        'transformed_locations.longtitude'
      )
      .each do |license|
        sim = sim_locator.locate(license.latitude, license.longitude)
        next unless statistic_region_match?(sim, sim_unit, sim_area_code)

        key = [
          license.statistic_point_key,
          license.latitude,
          license.longitude
        ].join('|')
        group = groups[license.reported_at][key] ||= { detail: false, gastronomy: false, detail_licenses: 0, gastronomy_licenses: 0 }
        group[:detail] ||= license.business_category_name == 'detal'
        group[:gastronomy] ||= license.business_category_name == 'gastronomia'
        if license.business_category_name == 'detal'
          group[:detail_licenses] += license.licenses_count.to_i
        elsif license.business_category_name == 'gastronomia'
          group[:gastronomy_licenses] += license.licenses_count.to_i
        end
      end

    groups
  end

  def statistic_region_match?(sim, sim_unit, sim_area_code)
    return true if sim_unit.blank?
    return false unless sim
    return false if sim.fetch(:district) != sim_unit
    return false if sim_area_code.present? && sim.fetch(:code) != sim_area_code

    true
  end

  def premise_statistics(points)
    premises = points.each_with_object({}) do |point, memo|
      memo[point.fetch(:key)] ||= { detail: false, gastronomy: false }
      memo[point.fetch(:key)][:detail] ||= point.fetch(:business_categories).include?('detal')
      memo[point.fetch(:key)][:gastronomy] ||= point.fetch(:business_categories).include?('gastronomia')
    end.values

    premise_counts(premises)
  end

  def premise_counts(premises)
    {
      total: premises.size,
      gastronomy: premises.count { |premise| premise[:gastronomy] && !premise[:detail] },
      mixed: premises.count { |premise| premise[:gastronomy] && premise[:detail] },
      detail: premises.count { |premise| premise[:detail] && !premise[:gastronomy] }
    }
  end

  def license_counts(premises)
    premises.each_with_object({ total: 0, gastronomy: 0, mixed: 0, detail: 0 }) do |premise, counts|
      detail = premise[:detail_licenses].to_i
      gastronomy = premise[:gastronomy_licenses].to_i
      counts[:total] += detail + gastronomy

      if detail.positive? && gastronomy.positive?
        counts[:mixed] += detail + gastronomy
      elsif gastronomy.positive?
        counts[:gastronomy] += gastronomy
      elsif detail.positive?
        counts[:detail] += detail
      end
    end
  end

  def selected_population(snapshot, sim_unit, sim_area_code)
    record = if sim_unit.present? && sim_area_code.present?
               snapshot.fetch(:sim_units, {})[sim_area_code]
             elsif sim_unit.present?
               snapshot.fetch(:districts, {})[sim_unit]
             else
               snapshot[:city]
             end
    return unless record

    {
      total: record.fetch(:total).to_i,
      area_km2: record.fetch(:area_km2).to_f,
      observed_on: snapshot[:observed_on]
    }
  end

  def statistic_rates(count, population)
    return { per_1000_registered: nil, per_km2: nil } unless population

    total = population.fetch(:total).to_f
    area_km2 = population.fetch(:area_km2).to_f

    {
      per_1000_registered: total.positive? ? (count * 1_000.0 / total).round(2) : nil,
      per_km2: area_km2.positive? ? (count / area_km2).round(2) : nil
    }
  end

  def reports_with_changes(reports)
    first_total = reports.find { |report| report.fetch(:premises).fetch(:total).positive? }&.fetch(:premises)&.fetch(:total)
    previous_total = nil

    reports.map do |report|
      total = report.fetch(:premises).fetch(:total)
      report.merge(
        change_from_first_percent: percent_change(total, first_total),
        change_from_previous_percent: percent_change(total, previous_total)
      ).tap do
        previous_total = total
      end
    end
  end

  def percent_change(value, baseline)
    return if baseline.blank? || baseline.to_f.zero?

    ((value.to_f - baseline.to_f) * 100.0 / baseline.to_f).round(2)
  end

  def legacy_license_points(report_at)
    AlcoholLicense
      .joins(:business, :business_category, :license_category, location: :transformed_location)
      .where(reported_at: report_at)
      .where.not(transformed_locations: { latitude: nil, longtitude: nil })
      .select(
        'alcohol_licenses.id',
        'alcohol_licenses.expires_at',
        'businesses.name AS business_name',
        'business_categories.name AS business_category_name',
        'license_categories.name AS license_category_name',
        'locations.address_1 AS source_address_1',
        'locations.address_2 AS source_address_2',
        'transformed_locations.address_1 AS address_1',
        'transformed_locations.building_number AS building_number',
        'transformed_locations.latitude AS latitude',
        'transformed_locations.longtitude AS longitude'
      )
      .map do |license|
        {
          id: license.id,
          lat: license.latitude,
          lng: license.longitude,
          business: license.business_name,
          business_category: license.business_category_name,
          license_category: license.license_category_name,
          address: display_address(license),
          expires_at: license.expires_at&.to_date
        }
      end
  end

  def display_address(license)
    [
      license.address_1.presence || license.source_address_1,
      license.building_number.presence || license.source_address_2
    ].compact.join(' ')
  end
end
