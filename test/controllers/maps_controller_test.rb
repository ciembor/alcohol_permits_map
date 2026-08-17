require 'test_helper'

class MapsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @business_category = BusinessCategory.create!(name: 'detal')
    @gastronomy_category = BusinessCategory.create!(name: 'gastronomia')
    @license_category = LicenseCategory.create!(name: 'A')
    @business = Business.create!(name: 'TEST')
    @similar_business = Business.create!(name: 'TEST SPÓŁKA Z O.O.')
    @other_business = Business.create!(name: 'OTHER TEST')
    transformed_location = TransformedLocation.create!(
      address_1: 'Długa',
      building_number: '10',
      address_kind: 'street_address',
      parcel_cadastral_unit: 'srodmiescie',
      parcel_region: '14',
      latitude: 50.0641,
      longtitude: 19.9391
    )
    @location = Location.create!(
      address_1: 'DŁUGA',
      address_2: '10',
      transformed_location: transformed_location
    )
    AlcoholLicense.create!(
      business: @business,
      business_category: @gastronomy_category,
      license_category: @license_category,
      location: @location,
      reported_at: Time.utc(2026, 2, 6, 8, 43, 9),
      expires_at: Time.utc(2027, 1, 1)
    )
    AlcoholLicense.create!(
      business: @business,
      business_category: @business_category,
      license_category: @license_category,
      location: @location,
      reported_at: Time.utc(2026, 2, 6, 8, 43, 9),
      expires_at: Time.utc(2027, 1, 1)
    )
    AlcoholLicense.create!(
      business: @other_business,
      business_category: @business_category,
      license_category: @license_category,
      location: @location,
      reported_at: Time.utc(2026, 2, 6, 8, 43, 9),
      expires_at: Time.utc(2027, 1, 1)
    )
    AlcoholLicense.create!(
      business: @similar_business,
      business_category: @business_category,
      license_category: @license_category,
      location: @location,
      reported_at: Time.utc(2026, 2, 6, 8, 43, 9),
      expires_at: Time.utc(2027, 1, 1)
    )
    SimPopulation.create!(
      observed_on: Date.new(2025, 12, 31),
      observed_on_code: 20251231,
      sim_unit_code: 'I.1',
      sim_unit_name: 'Stare Miasto',
      district_code: 'I',
      district_name: 'Dzielnica I Stare Miasto',
      total: 1_000
    )
    SimPopulation.create!(
      observed_on: Date.new(2025, 12, 31),
      observed_on_code: 20251231,
      sim_unit_code: 'VIII.1',
      sim_unit_name: 'Debniki',
      district_code: 'VIII',
      district_name: 'Dzielnica VIII Debniki',
      total: 3_000
    )
    LicensePointGroupBuilder.rebuild!(reported_at: Time.utc(2026, 2, 6, 8, 43, 9))
  end

  test 'renders map page' do
    get map_path

    assert_response :success
    assert_select 'html[lang="pl"]'
    assert_select '#license-map'
    assert_select '#report-slider'
    assert_select '#sim-scope'
    assert_select '#sim-area'
    assert_select 'h1', text: /Zezwolenia na sprzedaż/
    assert_select 'a[href="https://maciej-ciemborowicz.eu"][target="_blank"][rel="noopener"]'
    assert_select 'a[href="https://www.facebook.com/DobraNocKrakow"][target="_blank"][rel="noopener"]'
    assert_select 'a[href="https://zenodo.org/records/21895077"][target="_blank"][rel="noopener"]', text: 'Zbiór Danych'
    assert_select 'a[href="https://github.com/ciembor/alcohol_permits_map"][target="_blank"][rel="noopener"]', text: 'Repozytorium'
    assert_includes response.body, 'data-language-urls'
    assert_includes response.body, 'data-cache-version'
  end

  test 'renders map page in English' do
    get map_path(locale: 'en')

    assert_response :success
    assert_select 'html[lang="en"]'
    assert_select 'h1', text: /Alcohol-sale licenses/
    assert_select 'a[href="https://zenodo.org/records/21895077"]', text: 'Dataset'
    assert_select 'a[href="https://github.com/ciembor/alcohol_permits_map"]', text: 'Repository'
    assert_includes response.body, 'Premises density'
    assert_includes response.body, 'data-language-urls'
    assert_includes response.body, '&quot;pl&quot;:&quot;/map&quot;'
  end

  test 'returns geocoded license points for selected year' do
    get map_licenses_path(report_at: '2026-02-06T08:43:09Z')

    assert_response :success
    body = JSON.parse(response.body)
    summary = body.fetch('summary')
    population = body.fetch('population')
    points = body.fetch('points')
    point = points.first

    assert_equal 2026, body.fetch('year')
    assert_equal 4, summary.fetch('total')
    assert_equal 4, summary.fetch('geocoded')
    assert_equal 100.0, summary.fetch('geocoded_percent')
    assert_equal 'detal', summary.fetch('by_business_category').first.fetch('name')
    assert_equal '2025-12-31', population.fetch('observed_on')
    assert_equal 4_000, population.fetch('city').fetch('total')
    assert_operator population.fetch('city').fetch('area_km2'), :>, 0
    assert_equal 1_000, population.fetch('districts').fetch('Dzielnica I Stare Miasto').fetch('total')
    assert_operator population.fetch('districts').fetch('Dzielnica I Stare Miasto').fetch('area_km2'), :>, 0
    assert_equal 1_000, population.fetch('sim_units').fetch('I.1').fetch('total')
    assert_operator population.fetch('sim_units').fetch('I.1').fetch('area_km2'), :>, 0
    assert_equal 2, points.size
    assert_equal ['OTHER TEST', 'TEST'], points.map { |item| item.fetch('business') }.sort
    mixed_point = points.find { |item| item.fetch('business') == 'TEST' }

    assert mixed_point.fetch('point_group_id')
    assert_equal ['TEST', 'TEST SPÓŁKA Z O.O.'], mixed_point.fetch('businesses')
    assert_equal 2, mixed_point.fetch('business_count')
    assert_equal 2, mixed_point.fetch('business_id_count')
    details = mixed_point.fetch('business_license_details')
    test_details = details.find { |detail| detail.fetch('business') == 'TEST' }
    similar_details = details.find { |detail| detail.fetch('business') == 'TEST SPÓŁKA Z O.O.' }

    assert_equal 2, details.size
    assert_equal 2, test_details.fetch('license_count')
    assert_equal ['detal', 'gastronomia'], test_details.fetch('category_details').map { |detail| detail.fetch('business_category') }.sort
    assert_equal 1, similar_details.fetch('license_count')
    assert_equal ['detal'], similar_details.fetch('category_details').map { |detail| detail.fetch('business_category') }
    assert_equal ['detal', 'gastronomia'], mixed_point.fetch('business_categories')
    assert_equal({ 'detal' => 2, 'gastronomia' => 1 }, mixed_point.fetch('license_counts_by_business_category'))
    assert_equal 'A', mixed_point.fetch('license_category')
    assert_equal ['A'], mixed_point.fetch('license_categories')
    assert_equal({ 'A' => 3 }, mixed_point.fetch('license_counts_by_category'))
    assert_equal 3, mixed_point.fetch('license_count')
    assert_equal 'Dzielnica I Stare Miasto', mixed_point.fetch('sim_unit')
    assert_equal ['Dzielnica I Stare Miasto'], mixed_point.fetch('sim_units')
    assert_equal 'Stare Miasto', mixed_point.fetch('sim_area')
    assert_equal ['Stare Miasto'], mixed_point.fetch('sim_areas')
    assert_equal 'I.1', mixed_point.fetch('sim_area_code')
    assert_equal 50.0641, mixed_point.fetch('lat')
    assert_equal 19.9391, mixed_point.fetch('lng')
  end

  test 'resolves date-only report parameter to that report instead of latest report' do
    AlcoholLicense.create!(
      business: @business,
      business_category: @business_category,
      license_category: @license_category,
      location: @location,
      reported_at: Time.utc(2025, 2, 27, 14, 5, 43),
      expires_at: Time.utc(2026, 1, 1)
    )
    LicensePointGroupBuilder.rebuild!(reported_at: Time.utc(2025, 2, 27, 14, 5, 43))

    get map_licenses_path(report_at: '2025-02-27')

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal '2025-02-27T14:05:43.000Z', body.fetch('report_at')
    assert_equal 1, body.fetch('summary').fetch('total')
  end

  test 'materializes report cache on first request and reuses it afterwards' do
    report_at = Time.utc(2026, 2, 6, 8, 43, 9)
    cache_root = Rails.root.join('tmp/tests/map-report-cache')
    cache_path = cache_root.join('unit-test', '2026-02-06T08-43-09Z.json')
    FileUtils.rm_rf(cache_root)

    with_modified_env(
      'ALKOMAPA_REPORT_CACHE_IN_TEST' => '1',
      'ALKOMAPA_REPORT_CACHE_ROOT' => cache_root.to_s,
      'ALKOMAPA_DATA_CACHE_VERSION' => 'unit-test'
    ) do
      get map_licenses_path(report_at: report_at.iso8601)

      assert_response :success
      assert cache_path.exist?
      assert_equal 2, JSON.parse(cache_path.read).fetch('points').size

      AlcoholLicense.where.not(id: AlcoholLicense.minimum(:id)).delete_all
      get map_licenses_path(report_at: report_at.iso8601)

      assert_response :success
      assert_equal 2, JSON.parse(response.body).fetch('points').size
    end
  ensure
    FileUtils.rm_rf(cache_root)
  end

  test 'uses deploy cache version in report cache path' do
    report_at = Time.utc(2026, 2, 6, 8, 43, 9)

    with_modified_env('ALKOMAPA_DATA_CACHE_VERSION' => 'release/one') do
      assert_includes MapsController.new.send(:report_cache_path, report_at).to_s,
        '/cache/release-one/2026-02-06T08-43-09Z.json'
    end
  end

  test 'locates Kazimierz with official SIM polygons' do
    sim = Sim::Locator.new.locate(50.052, 19.945)

    assert_equal 'Dzielnica I Stare Miasto', sim.fetch(:district)
    assert_equal 'I.8', sim.fetch(:code)
    assert_equal 'Kazimierz', sim.fetch(:name)
  end

  test 'returns compact time series statistics for selected region and filters' do
    get map_statistics_path(
      sim_unit: 'Dzielnica I Stare Miasto',
      sim_area_code: 'I.1',
      business_categories: ['detal', 'gastronomia'],
      business_categories_selected: '1',
      license_categories: ['A'],
      license_categories_selected: '1'
    )

    assert_response :success
    body = JSON.parse(response.body)
    report = body.fetch('reports').first

    assert_equal ['detal', 'gastronomia'], body.fetch('filters').fetch('business_categories')
    assert_equal 2, report.fetch('premises').fetch('total')
    assert_equal 0, report.fetch('premises').fetch('gastronomy')
    assert_equal 1, report.fetch('premises').fetch('mixed')
    assert_equal 1, report.fetch('premises').fetch('detail')
    assert_equal 1_000, report.fetch('population').fetch('total')
    assert_operator report.fetch('population').fetch('area_km2'), :>, 0
    assert_equal 2.0, report.fetch('rates').fetch('per_1000_registered')
    assert_nil report.fetch('change_from_previous_percent')
    assert_equal 0.0, report.fetch('change_from_first_percent')
  end

  private

  def with_modified_env(values)
    previous = values.transform_values { |_value| nil }
    values.each do |key, value|
      previous[key] = ENV[key]
      ENV[key] = value
    end
    yield
  ensure
    previous.each do |key, value|
      if value.nil?
        ENV.delete(key)
      else
        ENV[key] = value
      end
    end
  end
end
