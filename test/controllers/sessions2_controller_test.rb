require 'test_helper'

class Sessions2ControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get sessions2_new_url
    assert_response :success
  end

end
