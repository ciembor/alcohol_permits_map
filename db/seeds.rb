# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
#

license_categories = {
  'A' => 'napoje o zawartości alkoholu do 4,5% oraz piwo',
  'B' => 'napoje o zawartości alkoholu powyżej 4,5% do 18% (z wyjatkiem piwa)',
  'C' => 'napoje o zawartości alkoholu powyżej 18%'
}

license_categories.each do |name, description|
  LicenseCategory.create!({
    name: name,
    description: description
  })
end

['detal', 'gastronomia'].each do |name|
  BusinessCategory.create!(name: name)
end

