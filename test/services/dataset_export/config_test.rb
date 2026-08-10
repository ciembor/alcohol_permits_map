require 'test_helper'

class DatasetExport::ConfigTest < ActiveSupport::TestCase
  test 'builds config from environment-like hash' do
    config = DatasetExport::Config.from_env(
      'VERSION' => 'v2.1.0',
      'OUTPUT_DIR' => 'tmp/custom',
      'INCLUDE_BUSINESS_NAMES' => '1',
      'INCLUDE_SOURCE_FILES' => '0',
      'LATEST_ONLY' => 'true'
    )

    assert_equal 'v2.1.0', config.version
    assert_equal Pathname('tmp/custom'), config.output_dir
    assert config.include_business_names
    refute config.include_source_files
    assert config.latest_only
    assert_equal 'krakow-alcohol-licenses-2010-2026-v2.1.0', config.release_name
  end

  test 'includes source files by default' do
    assert DatasetExport::Config.from_env({}).include_source_files
  end
end

