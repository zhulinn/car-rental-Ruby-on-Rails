require 'test_helper'

class Sessions3ControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get sessions3_new_url
    assert_response :success
  end

end
