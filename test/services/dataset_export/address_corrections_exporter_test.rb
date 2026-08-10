require 'test_helper'
require 'csv'
require 'tmpdir'

class DatasetExport::AddressCorrectionsExporterTest < ActiveSupport::TestCase
  setup do
    clear_dataset_records
    seed_address_correction_records
  end

  teardown do
    clear_dataset_records
  end

  test 'writes address correction rows with public raw location ids' do
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'address_corrections.csv')
      count = DatasetExport::Exporters::AddressCorrectionsExporter.new(path: path).write

      assert_equal 2, count

      csv = CSV.read(path, headers: true, encoding: 'UTF-8')
      assert_equal DatasetExport::AddressCorrectionRows::COLUMNS, csv.headers
      assert_equal 2, csv.map { |row| row.fetch('correction_id') }.uniq.size
      assert csv.all? { |row| row.fetch('correction_id').start_with?('address-correction-') }

      selected = csv.find { |row| row.fetch('selected') == 'true' }
      assert selected.fetch('raw_location_id').start_with?('raw-location-')
      assert selected.fetch('source_raw_location_id').start_with?('raw-location-')
      assert_equal 'manual', selected.fetch('source')
      assert_equal 'review', selected.fetch('method')
      assert_equal '2026-01-01T00:00:00Z', selected.fetch('created_at')

      inferred = csv.find { |row| row.fetch('selected') == 'false' }
      assert_nil inferred.fetch('source_raw_location_id')
    end
  end

  private

  def seed_address_correction_records
    target = Location.create!(address_1: 'RYNEK', address_2: '1')
    source = Location.create!(address_1: 'RYNEK GŁÓWNY', address_2: '1')

    AddressCorrection.create!(
      location: target,
      source_location: source,
      corrected_address_1: 'Rynek Główny',
      corrected_address_2: '1',
      source: 'manual',
      method: 'review',
      confidence: 1.0,
      selected: true,
      evidence: 'test evidence',
      created_at: Time.utc(2026, 1, 1),
      updated_at: Time.utc(2026, 1, 1)
    )
    AddressCorrection.create!(
      location: source,
      corrected_address_1: 'Rynek',
      corrected_address_2: '1',
      source: 'inferred',
      method: 'normalization',
      confidence: 0.7,
      selected: false,
      evidence: 'test inferred evidence',
      created_at: Time.utc(2026, 1, 2),
      updated_at: Time.utc(2026, 1, 2)
    )
  end

  def clear_dataset_records
    AddressCorrection.delete_all
    Location.delete_all
  end
end
