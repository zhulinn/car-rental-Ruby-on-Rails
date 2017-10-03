require 'test_helper'

class SuperAdminTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test 'should have name' do
    assert_not SuperAdmin.new(email: 'sadmin@email.com', password: 'password').save
  end

  test 'should have email' do
    assert_not SuperAdmin.new(name: 'name', password: 'password').save
  end

  test 'should have password' do
    assert_not SuperAdmin.new(name: 'name', email: 'sadmin@email.com').save
  end

  test 'should have unique email' do
    SuperAdmin.new(name: 'name1', email: 'xxx@email.com', password: 'password').save
    assert_not SuperAdmin.new(name: 'name2', email: 'xxx@email.com', password: 'password').save
  end
end
