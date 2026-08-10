require 'test_helper'
require 'location_transformer/transformer'

class LocationTransformer::TransformerTest < ActiveSupport::TestCase
  setup do
    Street.create!(name_1: 'Dietla', name_2: 'Józefa')
  end

  test 'splits embedded building number from address_1 only when street is known' do
    transformer = LocationTransformer::Transformer.new

    parsed_address = transformer.send(:parse_address_parts, 'JÓZEFA DIETLA 44/50/ STRADOMSKA 18', nil)

    assert_equal 'JÓZEFA DIETLA', parsed_address[:address_1]
    assert_equal '44/50/ STRADOMSKA 18', parsed_address[:address_2]
  end

  test 'does not split numbered street names' do
    transformer = LocationTransformer::Transformer.new

    parsed_address = transformer.send(:parse_address_parts, 'ALEJA 29 LISTOPADA', nil)

    assert_equal 'ALEJA 29 LISTOPADA', parsed_address[:address_1]
    assert_nil parsed_address[:address_2]
  end

  test 'uses selected address correction before parsing source address fields' do
    location = Location.create!(address_1: 'DŁUGA')
    AddressCorrection.create!(
      location: location,
      corrected_address_1: 'DŁUGA',
      corrected_address_2: '10',
      source: 'test',
      method: 'manual',
      confidence: 1.0,
      selected: true
    )

    parsed_address = LocationTransformer::Transformer.new.send(:parse_address_parts, location)

    assert_equal 'DŁUGA', parsed_address[:address_1]
    assert_equal '10', parsed_address[:address_2]
  end

  test 'splits known street from address_2 before building number' do
    Street.create!(name_1: 'Żywiecka')
    Street.create!(name_1: 'Boczna')

    parsed_address = LocationTransformer::Transformer.new.send(:parse_address_parts, 'ŻYWIECKA', 'BOCZNA 2')

    assert_equal 'Boczna', parsed_address[:address_1]
    assert_equal '2', parsed_address[:address_2]
  end

  test 'normalizes bare Jozefa to Kazimierz street, not patron streets' do
    Street.create!(name_1: 'Becka', name_2: 'Józefa')
    Street.create!(name_1: 'Józefa')

    transformer = LocationTransformer::Transformer.new
    address_1 = transformer.send(:address_1_transformer).transform_address_1('JÓZEFA')

    assert_equal 'Józefa', address_1
  end

  test 'prefers exact short street names over patron street names' do
    Street.create!(name_1: 'Bacewiczówny', name_2: 'Grażyny')
    Street.create!(name_1: 'Grażyny')
    Street.create!(name_1: 'Chanieckiej', name_2: 'Heleny')
    Street.create!(name_1: 'Heleny')
    Street.create!(name_1: 'Bojki', name_2: 'Jakuba')
    Street.create!(name_1: 'Jakuba')

    transformer = LocationTransformer::Transformer.new
    address_1_transformer = transformer.send(:address_1_transformer)

    assert_equal 'Grażyny', address_1_transformer.transform_address_1('GRAŻYNY')
    assert_equal 'Heleny', address_1_transformer.transform_address_1('HELENY')
    assert_equal 'Jakuba', address_1_transformer.transform_address_1('JAKUBA')
  end

  test 'keeps additional official street names that are missing from local street data' do
    Street.create!(name_1: 'Dmowskiego', name_2: 'Romana')
    Street.create!(name_1: 'Żywiecka')
    Street.create!(name_1: 'Boczna')

    transformer = LocationTransformer::Transformer.new
    address_1_transformer = transformer.send(:address_1_transformer)

    assert_equal 'Romana Ciesielskiego', address_1_transformer.transform_address_1('ROMANA CIESIELSKIEGO')
    assert_equal 'Żywiecka Boczna', address_1_transformer.transform_address_1('ŻYWIECKA BOCZNA')
    assert_nil address_1_transformer.same_as_for('ROMANA CIESIELSKIEGO')
    assert_nil address_1_transformer.same_as_for('ŻYWIECKA BOCZNA')
  end

  test 'does not override official Komorowskiego street with source-specific correction' do
    Street.create!(name_1: 'Aleja gen. Tadeusza Bora-Komorowskiego')
    Street.create!(name_1: 'Komorowskiego', name_2: 'Bolesława')

    transformer = LocationTransformer::Transformer.new

    assert_equal 'Bolesława Komorowskiego',
      transformer.send(:address_1_transformer).transform_address_1('KOMOROWSKIEGO')
  end

  test 'does not normalize truncated general Wladyslawa avenue from fuzzy context' do
    Street.create!(name_1: 'Aleja gen. Władysława Andersa')
    Street.create!(name_1: 'Węzeł Drogowy im. kapitana Władysława Polesińskiego')

    transformer = LocationTransformer::Transformer.new

    assert_nil transformer.send(:address_1_transformer).transform_address_1('ALEJA GEN. WŁADYSŁAWA')
  end

  test 'does not normalize short Szwai and Lokietka through unrelated fuzzy matches' do
    Street.create!(name_1: 'Szlak')
    Street.create!(name_1: 'Łowiecka')
    Street.create!(name_1: 'Władysława Łokietka')

    transformer = LocationTransformer::Transformer.new
    address_1_transformer = transformer.send(:address_1_transformer)

    assert_nil address_1_transformer.transform_address_1('SZWAI')
    assert_nil address_1_transformer.transform_address_1('ŁOKIETKA')
  end

  test 'keeps historical street names and exposes current names as same_as' do
    transformer = LocationTransformer::Transformer.new
    address_1_transformer = transformer.send(:address_1_transformer)

    examples = {
      'BRACI CZECZÓW' => ['Braci Czeczów', 'Henryka i Karola Czeczów'],
      'EMILA DZIEDZICA' => ['Emila Dziedzica', 'Marka Eminowicza'],
      'FRANCISZKA KAJTY' => ['Franciszka Kajty', 'prof. Henryka Wereszyckiego'],
      'ZYGMUNTA MŁYNARSKIEGO' => ['Zygmunta Młynarskiego', 'Marka Nawary'],
      'LUCJANA SZENWALDA' => ['Lucjana Szenwalda', 'Majora Pilota Stefana Janusa'],
      'JANKA SZUMCA' => ['Janka Szumca', 'Wiktora Zina'],
      'JANA SZUMCA' => ['Janka Szumca', 'Wiktora Zina'],
      'SZUMCA' => ['Janka Szumca', 'Wiktora Zina'],
      'JANA SZWAI' => ['Jana Szwai', 'prof. Władysława Konopczyńskiego'],
      'IGNACEGO KRIEGERA' => ['Ignacego Kriegera', 'Rodziny Kriegerów']
    }

    examples.each do |raw_address, (old_name, new_name)|
      assert_equal old_name, address_1_transformer.transform_address_1(raw_address), raw_address
      assert_equal new_name, address_1_transformer.same_as_for(raw_address), raw_address
      assert_nil address_1_transformer.same_as_for(new_name), raw_address
    end
  end

  test 'normalizes source-specific places to TERYT street names' do
    Street.create!(name_1: 'Rynek Kleparski')
    Street.create!(name_1: 'Przylasek')
    Street.create!(name_1: 'Nad Zalewem')

    transformer = LocationTransformer::Transformer.new
    address_1_transformer = transformer.send(:address_1_transformer)

    examples = {
      'PLAC TARGOWY STARY KLEPARZ' => 'Rynek Kleparski',
      'PRZYLASEK RUSIECKI' => 'Przylasek',
      'TEREN PRZY ZALEWIE NOWOHUCKIM' => 'Nad Zalewem',
      'ZALEW NOWOHUCKI' => 'Nad Zalewem'
    }

    examples.each do |raw_address, canonical_name|
      assert_equal canonical_name, address_1_transformer.transform_address_1(raw_address), raw_address
      assert_nil address_1_transformer.same_as_for(raw_address), raw_address
    end
  end

  test 'stores current street name in transformed location same_as for historical address' do
    location = Location.create!(address_1: 'JANA SZWAI', address_2: '12')

    LocationTransformer::Transformer.new.transform_locations

    transformed_location = location.reload.transformed_location
    assert_equal 'Jana Szwai', transformed_location.address_1
    assert_equal '12', transformed_location.building_number
    assert_equal 'prof. Władysława Konopczyńskiego', transformed_location.same_as
  end

  test 'does not store historical street name in same_as for current address' do
    location = Location.create!(address_1: 'PROF. WŁADYSŁAWA KONOPCZYŃSKIEGO', address_2: '12')

    LocationTransformer::Transformer.new.transform_locations

    transformed_location = location.reload.transformed_location
    assert_equal 'PROF. WŁADYSŁAWA KONOPCZYŃSKIEGO', transformed_location.address_1
    assert_nil transformed_location.same_as
  end

  test 'clears stale raw address when transformed location is reused by blank source address' do
    Street.create!(name_1: 'Długa')
    stale_location = TransformedLocation.create!(
      address_1: 'Długa',
      address_kind: 'landmark',
      raw_address_2: '/HELCLÓW /działka ewid 115/40'
    )
    location = Location.create!(address_1: 'DŁUGA', transformed_location: stale_location)

    LocationTransformer::Transformer.new.transform_locations

    transformed_location = location.reload.transformed_location
    assert_equal stale_location.id, transformed_location.id
    assert_nil transformed_location.raw_address_2
  end
end
