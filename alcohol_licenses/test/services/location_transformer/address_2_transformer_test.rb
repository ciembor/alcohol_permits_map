require 'test_helper'
require 'location_transformer/address_2_transformer'

class LocationTransformer::Address2TransformerTest < ActiveSupport::TestCase
  setup do
    @transformer = LocationTransformer::Address2Transformer.new
  end

  test 'extracts building and unit from slash LU address' do
    address = @transformer.transform('10/LU3')

    assert_equal 'street_address', address[:address_kind]
    assert_equal '10', address[:building_number]
    assert_equal '3', address[:unit_number]
  end

  test 'extracts unit number from slash address' do
    examples = {
      '23/1' => ['23', '1'],
      '23/3' => ['23', '3'],
      '32A/15' => ['32A', '15'],
      '6 A/17 U' => ['6A', '17'],
      '12/1U' => ['12', '1U'],
      '48/A5' => ['48', 'A5'],
      '14A/XIII' => ['14A', 'XIII'],
      '10/L1A' => ['10', '1A'],
      '64/6UA' => ['64', '6UA'],
      '3/10LU' => ['3', '10LU'],
      '4/LO 1' => ['4', '1'],
      '8/UC1' => ['8', 'UC1'],
      '53A/US1' => ['53A', 'US1'],
      '22G/OU8' => ['22G', 'OU8'],
      '22G/0U8' => ['22G', 'OU8'],
      '14A/8"L"' => ['14A', '8L'],
      '13/1.2' => ['13', '1.2'],
      '4/PO 90' => ['4', 'PO90']
    }

    examples.each do |raw_address, (building_number, unit_number)|
      address = @transformer.transform(raw_address)

      assert_equal building_number, address[:building_number], raw_address
      assert_equal unit_number, address[:unit_number], raw_address
    end
  end

  test 'does not extract slash unit from compound street address' do
    examples = [
      '44/50/ STRADOMSKA 18',
      '27/św.Filipa 1/1',
      '26/ RAKOWICKA 2',
      '68/Śliska9 lok.U3,U4',
      '2/U4/Blich 5',
      '6 /wejście od ul.Siennej 1',
      '15/rynek kleparski 4 lok U',
      '12C ul. Mikołajczyka',
      '11/ul.Św. Tomasza'
    ]

    examples.each do |raw_address|
      address = @transformer.transform(raw_address)

      assert_nil address[:unit_number], raw_address
    end
  end

  test 'does not extract unit from later address segment' do
    address = @transformer.transform('17/LM3,15/LU1.LU2,LU 3,13/nr4')

    assert_equal 'compound_address', address[:address_kind]
    assert_equal '17', address[:building_number]
    assert_equal 'LM3', address[:unit_number]

    address = @transformer.transform('17LM3;15/LU1,LU2,LU3;13/ 4,5')

    assert_equal 'compound_address', address[:address_kind]
    assert_equal '17L', address[:building_number]
    assert_nil address[:unit_number]
  end

  test 'keeps first unit from multiple units in same address segment' do
    examples = {
      '19 lok 3,4' => ['19', '3'],
      '15/36,37,53,54' => ['15', '36'],
      '8 U1, U2' => ['8', '1']
    }

    examples.each do |raw_address, (building_number, unit_number)|
      address = @transformer.transform(raw_address)

      assert_equal building_number, address[:building_number], raw_address
      assert_equal unit_number, address[:unit_number], raw_address
    end
  end

  test 'does not treat budynek marker as building letter' do
    address = @transformer.transform('10 bud. nr 5')

    assert_equal 'street_address', address[:address_kind]
    assert_equal '10', address[:building_number]
  end

  test 'extracts building number wrapped in percent signs' do
    address = @transformer.transform('%16%')

    assert_equal 'street_address', address[:address_kind]
    assert_equal '16', address[:building_number]
  end

  test 'extracts block number from near-building address' do
    address = @transformer.transform('przy bl. nr 16')

    assert_equal 'near_building', address[:address_kind]
    assert_equal 'near', address[:address_relation]
    assert_equal '16', address[:building_number]
  end

  test 'keeps multi-building addresses as compound' do
    address = @transformer.transform('10 B, 10 C')

    assert_equal 'compound_address', address[:address_kind]
    assert_equal '10B', address[:building_number]
  end

  test 'extracts parcel number' do
    address = @transformer.transform('dz. nr 176/3')

    assert_equal 'parcel', address[:address_kind]
    assert_equal '176/3', address[:parcel_number]
  end

  test 'standardizes multiple parcel numbers with pipe separator' do
    address = @transformer.transform('166B /dz. 199 i 200 obr. 43/')

    assert_equal 'parcel', address[:address_kind]
    assert_equal '166B', address[:building_number]
    assert_equal '199|200', address[:parcel_number]
    assert_equal '43', address[:parcel_region]
  end

  test 'extracts parcel number after evidence marker' do
    address = @transformer.transform('/HELCLÓW /działka ewid 115/40')

    assert_equal 'parcel', address[:address_kind]
    assert_equal '115/40', address[:parcel_number]
  end

  test 'does not treat parcel marker after building number as building letter' do
    examples = {
      '16 działka 347/3' => ['16', '347/3'],
      '3 dz.14/7' => ['3', '14/7'],
      '22 dz. 27/10' => ['22', '27/10']
    }

    examples.each do |raw_address, (building_number, parcel_number)|
      address = @transformer.transform(raw_address)

      assert_equal 'parcel', address[:address_kind], raw_address
      assert_equal building_number, address[:building_number], raw_address
      assert_equal parcel_number, address[:parcel_number], raw_address
    end
  end

  test 'extracts parcel region and cadastral unit' do
    address = @transformer.transform('dz. 1/263 obr. 52 NOWA HUTA')

    assert_equal 'parcel', address[:address_kind]
    assert_equal '1/263', address[:parcel_number]
    assert_equal '52', address[:parcel_region]
    assert_equal 'nowa_huta', address[:parcel_cadastral_unit]
  end

  test 'extracts region from S-prefixed obr marker' do
    examples = ['DZ. 94 OBR. S-15 ŚRÓDMIEŚCIE', 'DZ. 94 OBR. S- 15 ŚRÓDMIEŚCIE']

    examples.each do |raw_address|
      address = @transformer.transform(raw_address)

      assert_equal 'parcel', address[:address_kind], raw_address
      assert_equal '94', address[:parcel_number], raw_address
      assert_equal '15', address[:parcel_region], raw_address
      assert_equal 'srodmiescie', address[:parcel_cadastral_unit], raw_address
    end
  end

  test 'standardizes multiple parcel regions with pipe separator' do
    address = @transformer.transform('działka 471/8 obr. 104,105')

    assert_equal 'parcel', address[:address_kind]
    assert_equal '471/8', address[:parcel_number]
    assert_equal '104|105', address[:parcel_region]
  end

  test 'recognizes typoed srodmiescie cadastral unit' do
    address = @transformer.transform('dz. 94 obr. śrdódmieście')

    assert_equal 'parcel', address[:address_kind]
    assert_equal '94', address[:parcel_number]
    assert_equal 'srodmiescie', address[:parcel_cadastral_unit]
  end

  test 'extracts krowodrza parcel region from dashed notation' do
    address = @transformer.transform('dz.112 obr 46-046')

    assert_equal 'parcel', address[:address_kind]
    assert_equal '112', address[:parcel_number]
    assert_equal '46', address[:parcel_region]
    assert_equal 'krowodrza', address[:parcel_cadastral_unit]
  end

  test 'treats kiosk number as pavilion-like described unit' do
    address = @transformer.transform('KIOSK NR 13')

    assert_equal 'pavilion', address[:address_kind]
    assert_equal '13', address[:unit_number]
  end

  test 'keeps landmark unit number when there is no building number' do
    address = @transformer.transform('lok 116')

    assert_equal 'landmark', address[:address_kind]
    assert_equal '116', address[:unit_number]
  end

  test 'does not treat local marker as building letter' do
    address = @transformer.transform('21 L.16')

    assert_equal 'street_address', address[:address_kind]
    assert_equal '21', address[:building_number]
  end

  test 'keeps spaced bare L as building letter because it is ambiguous' do
    address = @transformer.transform('30 L')

    assert_equal 'street_address', address[:address_kind]
    assert_equal '30L', address[:building_number]
  end

  test 'keeps spaced building letter before local marker' do
    address = @transformer.transform('19 A lok. 196')

    assert_equal 'street_address', address[:address_kind]
    assert_equal '19A', address[:building_number]
    assert_equal '196', address[:unit_number]
  end

  test 'does not treat compound address connector as building letter' do
    address = @transformer.transform('13 i 15')

    assert_equal 'compound_address', address[:address_kind]
    assert_equal '13', address[:building_number]
  end

  test 'does not treat level marker as building letter' do
    address = @transformer.transform('5 poziom + 1')

    assert_equal 'street_address', address[:address_kind]
    assert_equal '5', address[:building_number]
  end

  test 'does not treat described unit markers as building letters' do
    examples = {
      '20 kiosk 17' => '20',
      '8 U1, U2' => '8',
      '4 IIIp.' => '4',
      '13 seg. Z 2' => '13',
      '20 HALA F' => '20',
      '179 BOKS 116' => '179',
      '40 wejście od ujl. Pijarskiiej' => '40'
    }

    examples.each do |raw_address, building_number|
      address = @transformer.transform(raw_address)

      assert_equal building_number, address[:building_number], raw_address
    end
  end

  test 'extracts typoed local marker without treating it as building letter' do
    address = @transformer.transform('10 llok.nr 7')

    assert_equal 'street_address', address[:address_kind]
    assert_equal '10', address[:building_number]
    assert_equal '7', address[:unit_number]
  end

  test 'extracts unit number after local use marker' do
    examples = {
      '3 lok. U 3' => ['3', '3'],
      '3 LOK. -1' => ['3', '1'],
      '26 C lok. U 1' => ['26C', '1'],
      '43 U VII' => ['43', 'VII'],
      '8 U1, U2' => ['8', '1'],
      '1 lok L2' => ['1', 'L2'],
      '20 lok. A7' => ['20', 'A7'],
      '105 lok. LU/011' => ['105', '011'],
      '22G lok. OU 8' => ['22G', '8'],
      '3lok.27' => ['3', '27'],
      '77AlokU1' => ['77A', '1'],
      '7Blok. 2i 3' => ['7B', '2'],
      '4lok. PO 90' => ['4', 'PO90'],
      '6 lok. 2 A' => ['6', '2A'],
      '6 lok. 2 A i 3' => ['6', '2A'],
      '82 lok 2 i LU23' => ['82', '2'],
      '41 lok. 11 A 1' => ['41', '11']
    }

    examples.each do |raw_address, (building_number, unit_number)|
      address = @transformer.transform(raw_address)

      assert_equal building_number, address[:building_number], raw_address
      assert_equal unit_number, address[:unit_number], raw_address
    end
  end

  test 'keeps compact building letter when no unit marker is present' do
    address = @transformer.transform('30L')

    assert_equal 'street_address', address[:address_kind]
    assert_equal '30L', address[:building_number]
  end

  test 'extracts described unit after building number' do
    examples = {
      '20 kiosk nr 41' => ['20', '41'],
      '1 stoisko 54' => ['1', '54'],
      '20 HALA F' => ['20', 'F']
    }

    examples.each do |raw_address, (building_number, unit_number)|
      address = @transformer.transform(raw_address)

      assert_equal 'street_address', address[:address_kind], raw_address
      assert_equal building_number, address[:building_number], raw_address
      assert_equal unit_number, address[:unit_number], raw_address
    end
  end
end
