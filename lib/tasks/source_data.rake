namespace :source_data do
  desc 'Import license reports from normalized CSV files. Env: FILES=vendor/data/files/output/*.csv'
  task import_csv_reports: :environment do
    require 'csv'

    path = ENV.fetch('FILES', 'vendor/data/files/output/*.csv')

    Dir.glob(path).sort.each do |file|
      meta = File.basename(file, '.csv').split(' - ')
      puts "importing #{file}"

      reported_at = meta[0].to_datetime
      license_cat = LicenseCategory.find_by!(name: meta[2])
      business_cat = BusinessCategory.find_by!(name: meta[1])

      CSV.parse(File.read(file), headers: true, converters: [:date]).each do |row|
        location = Location.find_or_create_by!(
          address_1: row['address_1'],
          address_2: row['address_2']
        )
        business = Business.find_or_create_by!(name: row['name'])

        AlcoholLicense.find_or_create_by!(
          location: location,
          business: business,
          license_category: license_cat,
          business_category: business_cat,
          reported_at: reported_at,
          expires_at: row['expiration_date']
        )
      end
    end
  end

  desc 'Import license reports from XLSX and XLS files. Env: FILES=vendor/data/xlsx/*.xls*'
  task import_spreadsheet_reports: :environment do
    SpreadsheetImporter.new.import_files(ENV.fetch('FILES', 'vendor/data/xlsx/*.xls*'))
  end

  desc 'Import all license reports available locally'
  task import_license_reports: :environment do
    Rake::Task['source_data:import_csv_reports'].invoke
    Rake::Task['source_data:import_spreadsheet_reports'].invoke
  end
end
