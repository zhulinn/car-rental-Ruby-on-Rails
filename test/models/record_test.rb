require 'test_helper'

class RecordTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test 'should save' do
    assert Record.new(
      customer: Customer.new, car: Car.new,
      start: Time.now, end: Time.now,
      status: 'Reserved', hours: 1
    ).save
  end
end
