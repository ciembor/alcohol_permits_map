require 'test_helper'
require 'tmpdir'
require 'source_data/license_report_source_selector'

class SourceData::LicenseReportSourceSelectorTest < ActiveSupport::TestCase
  test 'imports pdf-extracted csv only at least seven days after the last spreadsheet report date' do
    Dir.mktmpdir do |dir|
      root = Pathname(dir)
      csv_dir = root.join('csv')
      xlsx_dir = root.join('xlsx')
      FileUtils.mkdir_p(csv_dir)
      FileUtils.mkdir_p(xlsx_dir)

      before_last_spreadsheet_csv = csv_dir.join('2020-08-05 10:00:00 - detal - A.csv')
      last_spreadsheet_day_csv = csv_dir.join('2021-04-15 13:25:58 - detal - A.csv')
      too_close_csv = csv_dir.join('2021-04-16 13:25:58 - detal - A.csv')
      after_gap_csv = csv_dir.join('2021-04-22 13:25:58 - detal - A.csv')
      earlier_spreadsheet = xlsx_dir.join('detal_A_2020_08_04.xlsx')
      last_spreadsheet = xlsx_dir.join('detal_A_2021_04_15.xlsx')

      before_last_spreadsheet_csv.write("index,address_1\n1,Rynek\n")
      last_spreadsheet_day_csv.write("index,address_1\n1,Florianska\n")
      too_close_csv.write("index,address_1\n1,Plac Nowy\n")
      after_gap_csv.write("index,address_1\n1,Dluga\n")
      earlier_spreadsheet.write('placeholder')
      last_spreadsheet.write('placeholder')

      selector = SourceData::LicenseReportSourceSelector.new(
        csv_glob: csv_dir.join('*.csv').to_s,
        spreadsheet_glob: xlsx_dir.join('*.xlsx').to_s
      )

      assert_equal Date.new(2021, 4, 15), selector.last_spreadsheet_report_date
      assert_equal Date.new(2021, 4, 22), selector.first_csv_report_date_after_spreadsheets
      assert_equal [after_gap_csv.to_s], selector.preferred_csv_files
      assert_equal [before_last_spreadsheet_csv.to_s, last_spreadsheet_day_csv.to_s, too_close_csv.to_s], selector.skipped_csv_files
      assert_equal [earlier_spreadsheet.to_s, last_spreadsheet.to_s], selector.spreadsheet_files
    end
  end

  test 'imports all csv files when no spreadsheet reports exist' do
    Dir.mktmpdir do |dir|
      root = Pathname(dir)
      csv_dir = root.join('csv')
      xlsx_dir = root.join('xlsx')
      FileUtils.mkdir_p(csv_dir)
      FileUtils.mkdir_p(xlsx_dir)

      csv = csv_dir.join('2020-08-04 13:29:58 - detal - B.csv')
      csv.write("index,address_1\n1,Rynek\n")

      selector = SourceData::LicenseReportSourceSelector.new(
        csv_glob: csv_dir.join('*.csv').to_s,
        spreadsheet_glob: xlsx_dir.join('*.xlsx').to_s
      )

      assert_nil selector.last_spreadsheet_report_date
      assert_equal [csv.to_s], selector.preferred_csv_files
      assert_empty selector.skipped_csv_files
    end
  end
end
