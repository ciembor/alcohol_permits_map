require 'test_helper'

class DeployScriptTest < ActiveSupport::TestCase
  test 'runs database migrations before restarting the deployed app' do
    script = Rails.root.join('scripts/deploy.sh').read

    assert_includes script, 'run_database_migrations()'
    assert_includes script, 'bundle exec rails db:migrate'
    assert_match(/run_database_migrations\n\s+restart_app_service/, script)
  end

  test 'deploy workflow warms map report cache' do
    workflow = Rails.root.join('.github/workflows/alcohol-permits-map-deploy.yml').read

    assert_includes workflow, 'WARM_REPORT_CACHE: "1"'
  end

  test 'report cache warmup retries transient response failures' do
    script = Rails.root.join('scripts/deploy.sh').read

    assert_includes script, 'WARM_REPORT_CACHE_ATTEMPTS="${WARM_REPORT_CACHE_ATTEMPTS:-3}"'
    assert_includes script, 'while ! curl --connect-timeout 2'
    assert_includes script, 'retry %s'
  end
end
