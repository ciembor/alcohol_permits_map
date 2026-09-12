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

  test 'report cache warmup retries transient failures in one runner' do
    script = Rails.root.join('scripts/deploy.sh').read

    assert_includes script, 'WARM_REPORT_CACHE_ATTEMPTS="${WARM_REPORT_CACHE_ATTEMPTS:-3}"'
    assert_includes script, 'while ! RUN_RELEASE_CONTAINER_TIMEOUT="${WARM_REPORT_CACHE_TIMEOUT}" run_release_container "${SERVICE_NAME}-report-cache"'
    assert_includes script, 'Report cache warm-up failed; retry %s'
  end

  test 'report cache warmup uses a single timeout for the batch runner' do
    script = Rails.root.join('scripts/deploy.sh').read

    assert_includes script, 'WARM_REPORT_CACHE_TIMEOUT="${WARM_REPORT_CACHE_TIMEOUT:-900}"'
    assert_includes script, 'RUN_RELEASE_CONTAINER_TIMEOUT="${WARM_REPORT_CACHE_TIMEOUT}"'
    assert_includes script, 'timeout "${RUN_RELEASE_CONTAINER_TIMEOUT}" "${podman_command[@]}" "$@"'
  end

  test 'report cache warmup builds all reports in one Rails process' do
    script = Rails.root.join('scripts/deploy.sh').read

    assert_includes script, 'reports = controller.send(:available_reports)'
    assert_includes script, 'reports.each do |report|'
    assert_includes script, 'Warmed #{reports.size} map report caches'
    assert_no_match(/SERVICE_NAME}-reports/, script)
    assert_no_match(/WARM_REPORT_AT/, script)
  end

  test 'deploy verifies warmed map report cache before activating release' do
    script = Rails.root.join('scripts/deploy.sh').read

    assert_includes script, 'verify_report_cache()'
    assert_includes script, 'expected_count="$(report_count)"'
    assert_includes script, "actual_count=\"$(find \"${cache_dir}\" -type f -name '*.json' | wc -l | tr -d '[:space:]')\""
    assert_match(/warm_report_cache.*verify_report_cache.*compress_report_cache/m, script)
  end

  test 'deploy precompresses warmed map report cache outside the app process' do
    script = Rails.root.join('scripts/deploy.sh').read

    assert_includes script, 'compress_report_cache()'
    assert_includes script, "find \"${cache_dir}\" -type f -name '*.json' -exec gzip -kf {} +"
    assert_match(/warm_report_cache.*compress_report_cache/m, script)
  end
end
