require 'test_helper'

class CustomerTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test 'should have name' do
    assert_not Customer.new(email: 'user@email.com', password: 'password').save
  end

  test 'should have email' do
    assert_not Customer.new(name: 'name', password: 'password').save
  end

  test 'should have password' do
    assert_not Customer.new(name: 'name', email: 'user@email.com').save
  end

  test 'should have unique email' do
    Customer.new(name: 'name1', email: 'xxx@email.com', password: 'password').save
    assert_not Customer.new(name: 'name2', email: 'xxx@email.com', password: 'password').save
  end
end
