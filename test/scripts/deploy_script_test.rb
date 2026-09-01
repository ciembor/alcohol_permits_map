require 'test_helper'

class DeployScriptTest < ActiveSupport::TestCase
  test 'runs database migrations before restarting the deployed app' do
    script = Rails.root.join('scripts/deploy.sh').read

    assert_includes script, 'run_database_migrations()'
    assert_includes script, 'bundle exec rails db:migrate'
    assert_match(/run_database_migrations\n\s+restart_app_service/, script)
  end
end
