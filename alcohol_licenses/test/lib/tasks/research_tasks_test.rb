require 'test_helper'
require 'rake'

class ResearchTasksTest < ActiveSupport::TestCase
  setup do
    Rails.application.load_tasks unless Rake::Task.task_defined?('research:full_open_pipeline')
  end

  test 'registers canonical research pipeline tasks' do
    expected_tasks = %w[
      source_data:import_csv_reports
      source_data:import_spreadsheet_reports
      source_data:import_license_reports
      streets:import_simc
      sim:import_population
      locations:infer_address_corrections
      locations:normalize
      research:import_sources
      research:normalize_locations
      research:geocode_open
      research:geocode_google_quality_control
      research:rebuild_analysis
      research:write_grouping_audit
      research:release_dataset
      research:prepare_zenodo_repository
      research:full_open_pipeline
    ]

    expected_tasks.each do |task_name|
      assert Rake::Task.task_defined?(task_name), "missing #{task_name}"
    end
  end

  test 'does not register legacy top-level task names' do
    legacy_tasks = %w[
      import_csv_files
      import_spreadsheet
      import_simc_streets
      transform_location
      source_data:import_csv_files
      source_data:import_spreadsheets
      source_data:import_all
      sim_population:import
      geocoding:google_uncertain_locations
    ]

    legacy_tasks.each do |task_name|
      assert_not Rake::Task.task_defined?(task_name), "legacy task still registered: #{task_name}"
    end
  end
end
