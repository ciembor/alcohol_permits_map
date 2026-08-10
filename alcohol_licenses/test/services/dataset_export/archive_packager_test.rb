require 'test_helper'
require 'tmpdir'
require 'zip'

class DatasetExport::ArchivePackagerTest < ActiveSupport::TestCase
  test 'writes zip archive containing only release files under release directory' do
    Dir.mktmpdir do |dir|
      config = DatasetExport::Config.new(version: 'v-test-archive', output_dir: dir)
      paths = DatasetExport::Paths.new(config)
      paths.mkdirs
      File.write(paths.readme_md, "readme\n")
      File.write(paths.checksums_txt, "checksum\n")
      FileUtils.mkdir_p(paths.tables_dir)
      File.write(paths.reports_csv, "report_id\nreport-1\n")

      report = DatasetExport::ArchivePackager.new(paths: paths).write_zip

      assert_equal paths.archive_zip.to_s, report.fetch(:archive_path)
      assert_equal 'krakow-alcohol-licenses-2010-2026-v-test-archive.zip', report.fetch(:archive_name)
      assert paths.archive_zip.exist?
      assert report.fetch(:archive_bytes).positive?
      assert_equal 64, report.fetch(:archive_sha256).length

      entries = Zip::File.open(paths.archive_zip) { |zip| zip.map(&:name) }
      assert_includes entries, 'krakow-alcohol-licenses-2010-2026-v-test-archive/README.md'
      assert_includes entries, 'krakow-alcohol-licenses-2010-2026-v-test-archive/checksums.txt'
      assert_includes entries, 'krakow-alcohol-licenses-2010-2026-v-test-archive/data/tables/reports.csv'
      assert_empty entries.grep(%r{(^|/)\.git/|(^|/)tmp/|development\.sqlite3|test\.sqlite3})
    end
  end
end
