require 'test_helper'

class HealthControllerTest < ActionDispatch::IntegrationTest
  test 'returns ok' do
    get healthz_path

    assert_response :success
    assert_empty response.body
  end
end
