namespace :source_data do
  desc 'Import license reports from normalized CSV files. Env: FILES=vendor/data/files/output/*.csv'
  task import_csv_reports: :environment do
    import_csv_report_files(Dir.glob(ENV.fetch('FILES', 'vendor/data/files/output/*.csv')).sort)
  end

  desc 'Import license reports from XLSX and XLS files. Env: FILES=vendor/data/xlsx/*.xls*'
  task import_spreadsheet_reports: :environment do
    SpreadsheetImporter.new.import_files(ENV.fetch('FILES', 'vendor/data/xlsx/*.xls*'))
  end

  desc 'Import XLS/XLSX reports and PDF-extracted CSV reports at least 7 days after the last spreadsheet date'
  task import_license_reports: :environment do
    require 'source_data/license_report_source_selector'

    selector = SourceData::LicenseReportSourceSelector.new(
      csv_glob: ENV.fetch('CSV_FILES', 'vendor/data/files/output/*.csv'),
      spreadsheet_glob: ENV.fetch('SPREADSHEET_FILES', 'vendor/data/xlsx/*.xls*')
    )

    puts "Importing #{selector.spreadsheet_files.size} spreadsheet report files"
    selector.spreadsheet_files.each do |file|
      SpreadsheetImporter.new.import_file(file)
    end

    skipped_count = selector.skipped_csv_files.size
    if skipped_count.positive?
      puts "Skipping #{skipped_count} PDF-extracted CSV files before the 7-day post-spreadsheet cutoff"
    end

    puts "Importing #{selector.preferred_csv_files.size} PDF-extracted CSV report files"
    import_csv_report_files(selector.preferred_csv_files)
  end

  def import_csv_report_files(files)
    require 'csv'

    files.sort.each do |file|
      meta = File.basename(file, '.csv').split(' - ')
      puts "importing #{file}"

      reported_at = meta[0].to_datetime
      license_cat = LicenseCategory.find_by!(name: meta[2])
      business_cat = BusinessCategory.find_by!(name: meta[1])

      csv_data = File.read(file, mode: 'rb')
        .force_encoding('UTF-8')
        .encode('UTF-8', invalid: :replace, undef: :replace, replace: '')

      CSV.parse(csv_data, headers: true, converters: [:date]).each do |row|
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
end
