require 'test_helper'

class AdminTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test 'should have name' do
    assert_not Admin.new(email: 'admin@email.com', password: 'password').save
  end

  test 'should have email' do
    assert_not Admin.new(name: 'name', password: 'password').save
  end

  test 'should have password' do
    assert_not Admin.new(name: 'name', email: 'admin@email.com').save
  end

  test 'should have unique email' do
    Admin.new(name: 'name1', email: 'xxx@email.com', password: 'password').save
    assert_not Admin.new(name: 'name2', email: 'xxx@email.com', password: 'password').save
  end
end
