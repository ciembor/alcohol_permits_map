require 'test_helper'

class DeployScriptTest < ActiveSupport::TestCase
  test 'runs database migrations before restarting the deployed app' do
    script = Rails.root.join('scripts/deploy.sh').read

    assert_includes script, 'run_database_migrations()'
    assert_includes script, 'bundle exec rails db:migrate'
    assert_match(/run_database_migrations\n\s+if ! warm_report_cache/m, script)
    assert_match(/write_release_env\n\s+sudo podman tag "\$\{RELEASE_IMAGE_NAME\}" "\$\{IMAGE_NAME\}"\n\s+restart_app_service/, script)
  end

  test 'deploy workflow warms map report cache' do
    workflow = Rails.root.join('.github/workflows/alcohol-permits-map-deploy.yml').read

    assert_includes workflow, 'WARM_REPORT_CACHE: "1"'
  end

  test 'report cache warmup retries transient response failures' do
    script = Rails.root.join('scripts/deploy.sh').read

    assert_includes script, 'WARM_REPORT_CACHE_ATTEMPTS="${WARM_REPORT_CACHE_ATTEMPTS:-3}"'
    assert_includes script, 'while ! WARM_REPORT_AT="${report_at}" run_release_container'
    assert_includes script, 'retry %s'
  end

  test 'deploy precompresses warmed map report cache outside the app process' do
    script = Rails.root.join('scripts/deploy.sh').read

    assert_includes script, 'compress_report_cache()'
    assert_includes script, "find \"${cache_dir}\" -type f -name '*.json' -exec gzip -kf {} +"
    assert_match(/warm_report_cache.*compress_report_cache/m, script)
  end
end
