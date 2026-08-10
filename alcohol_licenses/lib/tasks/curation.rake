namespace :curation do
  desc 'Export curated address corrections and geocoding decisions. Env: OUTPUT=db/curation/current.json'
  task export: :environment do
    require 'curation_snapshot'

    path = ENV.fetch('OUTPUT', CurationSnapshot::DEFAULT_PATH.to_s)
    result = CurationSnapshot.export!(path: path)
    puts "wrote #{path}"
    puts result.inspect
  end

  desc 'Import curated address corrections and geocoding decisions. Env: INPUT=db/curation/current.json'
  task import: :environment do
    require 'curation_snapshot'

    path = ENV.fetch('INPUT', CurationSnapshot::DEFAULT_PATH.to_s)
    result = CurationSnapshot.import!(path: path)
    puts "imported #{path}"
    puts result.inspect
  end

  desc 'Import only curated address corrections. Run after source import and before location normalization. Env: INPUT=db/curation/current.json'
  task import_address_corrections: :environment do
    require 'curation_snapshot'

    path = ENV.fetch('INPUT', CurationSnapshot::DEFAULT_PATH.to_s)
    count = CurationSnapshot.import_address_corrections!(path: path)
    puts "imported #{count} address corrections from #{path}"
  end

  desc 'Import selected geocoding decisions and manual reviews. Run after location normalization. Env: INPUT=db/curation/current.json'
  task import_geocoding_decisions: :environment do
    require 'curation_snapshot'

    path = ENV.fetch('INPUT', CurationSnapshot::DEFAULT_PATH.to_s)
    result = CurationSnapshot.import_geocoding_decisions!(path: path)
    puts "imported geocoding decisions from #{path}"
    puts result.inspect
  end
end
