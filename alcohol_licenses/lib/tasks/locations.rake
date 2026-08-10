namespace :locations do
  desc 'Infer address corrections from historical records'
  task infer_address_corrections: :environment do
    Rake::Task['address_corrections:infer_from_history'].invoke
  end

  desc 'Normalize raw locations into transformed_locations'
  task normalize: :environment do
    LocationTransformer::Transformer.new.transform_locations
  end
end
