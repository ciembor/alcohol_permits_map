require 'test_helper'

class DatasetExport::SourceFileIndexTest < ActiveSupport::TestCase
  test 'prefers extracted csv over pdf for the same logical report file' do
    index = DatasetExport::SourceFileIndex.new([
      {
        'reported_at' => '2026-02-06T08:43:09Z',
        'business_category' => 'detal',
        'license_category' => 'A',
        'file_format' => 'pdf',
        'relative_path' => 'report.pdf',
        'source_file_id' => 'source-file-pdf'
      },
      {
        'reported_at' => '2026-02-06T08:43:09Z',
        'business_category' => 'detal',
        'license_category' => 'A',
        'file_format' => 'csv',
        'relative_path' => 'report.csv',
        'source_file_id' => 'source-file-csv'
      }
    ])

    assert_equal 'source-file-csv', index.source_file_id(
      reported_at: Time.utc(2026, 2, 6, 8, 43, 9),
      business_category: 'detal',
      license_category: 'A'
    )
  end
end

