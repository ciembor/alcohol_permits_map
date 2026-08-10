
class SpreadsheetImporter
  def import_file(path)
    puts "Importing file #{path}"
    metadata = get_metadata(path)
    sheet = Roo::Spreadsheet.open(path)
    first_row_index = sheet.to_a.find_index { |a| a[0] == 'LP' } + 2
    (first_row_index..sheet.last_row).each do |index|
      import_record(sheet.row(index), metadata)
    end
  end

  def import_files(path = 'vendor/data/xlsx/*.xls*')
    Dir.glob(path).sort.each do |file|
      import_file(file)
    end
  end

  private

  def import_record(record, metadata)
    reported_at = Date.new(metadata[:year], metadata[:month], metadata[:day])
    address_1 = record[1]
    address_2 = record[2]
    business_name = record[3]
    expiration_date = record[4]

    location = Location.find_or_create_by!({
      address_1: address_1,
      address_2: address_2,
    })

    business = Business.find_or_create_by!({
      name: business_name
    })

    license_cat = LicenseCategory.find_by!({
      name: metadata[:license_category]
    })

    business_cat = BusinessCategory.find_by!({
      name: metadata[:business_category]
    })

    AlcoholLicense.create!({
      location: location,
      business: business,
      license_category: license_cat,
      business_category: business_cat,
      reported_at: reported_at,
      expires_at: expiration_date
    })
  end

  def get_metadata(file)
    meta = File.basename(file, File.extname(file)).split('_')
    {
      business_category: meta[0],
      license_category: meta[1],
      year: meta[2].to_i,
      month: meta[3].to_i,
      day: (meta[4] || 1).to_i
    }
  end
end
