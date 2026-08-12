require 'test_helper'
require 'tmpdir'
require 'fileutils'

class DatasetExport::SourceFilesManifestTest < ActiveSupport::TestCase
  test 'builds manifest rows for spreadsheets pdfs and extracted csv files' do
    Dir.mktmpdir do |dir|
      root = Pathname(dir)
      FileUtils.mkdir_p(root.join('vendor/data/xlsx'))
      FileUtils.mkdir_p(root.join('vendor/data/files/Wersja dokumentu z dnia 2026-02-06 08:43:09/detal'))
      FileUtils.mkdir_p(root.join('vendor/data/files/output'))

      root.join('vendor/data/xlsx/detal_A_2010_11.xls').write("spreadsheet\n")
      root.join('vendor/data/files/Wersja dokumentu z dnia 2026-02-06 08:43:09/detal/kategoria A - test.pdf').write("%PDF\n")
      root.join('vendor/data/files/output/2026-02-06 08:43:09 - detal - A.csv').write("index,address_1\n1,Rynek\n2,Florianska\n")

      rows = DatasetExport::SourceFilesManifest.new(root: root).rows

      assert_equal 3, rows.size
      assert_equal %w[csv pdf xls], rows.map { |row| row.fetch('file_format') }.sort
      assert rows.all? { |row| row.fetch('source_file_id').match?(/\Asource-file-[0-9a-f]{16}\z/) }

      csv_row = rows.find { |row| row.fetch('file_format') == 'csv' }
      assert_equal '2', csv_row.fetch('row_count_extracted').to_s
      assert_equal 'pdf_table_extraction', csv_row.fetch('source_origin')

      pdf_row = rows.find { |row| row.fetch('file_format') == 'pdf' }
      assert_equal '2026-02-06T08:43:09Z', pdf_row.fetch('reported_at')
      assert_equal 'detal', pdf_row.fetch('business_category')
      assert_equal 'A', pdf_row.fetch('license_category')
      assert_equal DatasetExport::SourceFilesManifest::BIP_ALCOHOL_LICENSES_URL, pdf_row.fetch('source_url')
      assert_match(/\A\d{4}-\d{2}-\d{2}T/, pdf_row.fetch('retrieved_at'))

      xls_row = rows.find { |row| row.fetch('file_format') == 'xls' }
      assert_equal '2010-11-01T00:00:00Z', xls_row.fetch('reported_at')
      assert_nil xls_row.fetch('source_url')
      assert_match(/\A\d{4}-\d{2}-\d{2}T/, xls_row.fetch('retrieved_at'))
      assert_includes xls_row.fetch('notes'), 'public-information-request response'
    end
  end

  test 'writes manifest csv with stable headers' do
    Dir.mktmpdir do |dir|
      root = Pathname(dir)
      FileUtils.mkdir_p(root.join('vendor/data/files/output'))
      root.join('vendor/data/files/output/2026-02-06 08:43:09 - detal - A.csv').write("index,address_1\n1,Rynek\n")

      output = root.join('manifest.csv')
      DatasetExport::SourceFilesManifest.new(root: root).write(output)

      csv = CSV.read(output, headers: true)
      assert_equal DatasetExport::SourceFilesManifest::COLUMNS, csv.headers
      assert_equal 1, csv.size
    end
  end
end
