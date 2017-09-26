require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get super_admin_login_path
    assert_response :success
  end

end
