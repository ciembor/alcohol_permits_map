namespace :address_corrections do
  desc 'Infer selected address corrections from historical records for locations with blank address_2'
  task infer_from_history: :environment do
    require 'location_transformer/address_correction_inferer'

    corrections = LocationTransformer::AddressCorrectionInferer.new.infer_all

    puts "created_or_existing=#{corrections.size}"
    corrections.each do |correction|
      puts [
        correction.location_id,
        correction.corrected_address_1,
        correction.corrected_address_2,
        correction.source,
        correction.method,
        correction.confidence
      ].join(' | ')
    end
  end
end
