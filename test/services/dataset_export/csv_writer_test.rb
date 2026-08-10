require 'test_helper'
require 'csv'
require 'tmpdir'

class DatasetExport::CsvWriterTest < ActiveSupport::TestCase
  test 'writes utf-8 csv with stable headers' do
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'nested', 'table.csv')
      count = DatasetExport::CsvWriter.write(
        path,
        %w[id name],
        [
          { 'id' => '1', 'name' => 'Kraków' }
        ]
      )

      assert_equal 1, count
      csv = CSV.read(path, headers: true, encoding: 'UTF-8')
      assert_equal %w[id name], csv.headers
      assert_equal 'Kraków', csv.first.fetch('name')
    end
  end
end

