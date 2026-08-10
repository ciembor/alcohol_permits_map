namespace :streets do
  desc 'Import TERC/SIMC street dictionary from CSV. Env: FILE=vendor/data/simc_streets.csv'
  task import_simc: :environment do
    require 'csv'

    path = ENV.fetch('FILE', 'vendor/data/simc_streets.csv')
    puts "importing #{path}"

    CSV.parse(File.read(path), headers: true, quote_char: '|', col_sep: ';').each do |row|
      Street.find_or_create_by!(
        trait: row[6],
        name_1: row[7],
        name_2: row[8]
      )
    end
  end
end
