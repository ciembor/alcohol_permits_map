namespace :research do
  desc 'Import local source data required by the research database'
  task import_sources: :environment do
    Rake::Task['streets:import_simc'].invoke
    Rake::Task['source_data:import_license_reports'].invoke
    Rake::Task['sim:import_population'].invoke
  end

  desc 'Infer corrections and normalize raw locations'
  task normalize_locations: :environment do
    Rake::Task['locations:infer_address_corrections'].invoke
    Rake::Task['locations:normalize'].invoke
  end

  desc 'Run open geocoding sources used by the public dataset. Env: LATEST_ONLY=1 LIMIT=100'
  task geocode_open: :environment do
    Rake::Task['geocoding:krakow_msip_address_points'].invoke
    Rake::Task['geocoding:gus_address_points'].invoke
    Rake::Task['geocoding:uldk_parcels'].invoke
    Rake::Task['geocoding:osm_missing_locations'].invoke
    Rake::Task['geocoding:sync_osm_locations'].invoke
  end

  desc 'Run optional Google quality-control geocoding. Requires GOOGLE_MAPS_API_KEY'
  task geocode_google_quality_control: :environment do
    Rake::Task['geocoding:google'].invoke
  end

  desc 'Rebuild analytical license point groups for all reports'
  task rebuild_analysis: :environment do
    ENV['ALL'] = '1'
    Rake::Task['license_point_groups:rebuild'].invoke
  end

  desc 'Write grouping audit checklist'
  task write_grouping_audit: :environment do
    Rake::Task['grouping_audit:write'].invoke
  end

  desc 'Export, validate, and package the public dataset release'
  task release_dataset: :environment do
    Rake::Task['dataset:release'].invoke
  end

  desc 'Prepare the external Zenodo publication repository from the generated release'
  task prepare_zenodo_repository: :environment do
    Rake::Task['dataset:prepare_publication_repo'].invoke
  end

  desc 'Run the full open-data pipeline without Google quality-control geocoding'
  task full_open_pipeline: :environment do
    Rake::Task['research:import_sources'].invoke
    Rake::Task['research:normalize_locations'].invoke
    Rake::Task['research:geocode_open'].invoke
    Rake::Task['research:rebuild_analysis'].invoke
    Rake::Task['research:release_dataset'].invoke
    Rake::Task['research:prepare_zenodo_repository'].invoke
  end
end
