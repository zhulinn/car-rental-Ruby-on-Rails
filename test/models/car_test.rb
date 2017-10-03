require 'test_helper'

class CarTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test 'should save' do
    assert Car.new(
      license: '1234567',
      manufacturer: 'xxx',
      model: 'xxx',
      rate: 1,
      style: 'SUV',
      location: 'xxx',
      status: 'Available'
    ).save
  end

  test 'should have license' do
    assert_not Car.new(
      manufacturer: 'xxx',
      model: 'xxx',
      rate: 1,
      style: 'SUV',
      location: 'xxx',
      status: 'Available'
    ).save
  end

  test'should have unique license' do
    Car.new(
      license: '1234567', manufacturer: 'xxx', model: 'xxx',
      rate: 1, style: 'SUV', location: 'xxx', status: 'Available'
    ).save
    assert_not Car.new(
      license: '1234567', manufacturer: 'xxx', model: 'xxx',
      rate: 1, style: 'SUV', location: 'xxx', status: 'Available'
    ).save
  end

  test 'should have 7-digit license' do
    assert_not Car.new(
      license: '12345678', manufacturer: 'xxx', model: 'xxx',
      rate: 1, style: 'SUV', location: 'xxx', status: 'Available'
    ).save
    assert_not Car.new(
      license: '123456', manufacturer: 'xxx', model: 'xxx',
      rate: 1, style: 'SUV', location: 'xxx', status: 'Available'
    ).save
    assert_not Car.new(
      license: '123456x', manufacturer: 'xxx', model: 'xxx',
      rate: 1, style: 'SUV', location: 'xxx', status: 'Available'
    ).save
  end

  test 'should have manufacturer' do
    assert_not Car.new(
      license: '1234567', model: 'xxx', rate: 1, style: 'SUV',
      location: 'xxx', status: 'Available'
    ).save
  end

  test 'should have model' do
    assert_not Car.new(
      license: '1234567', manufacturer: 'xxx', rate: 1,
      style: 'SUV', location: 'xxx', status: 'Available'
    ).save
  end

  test 'should have rate' do
    assert_not Car.new(
      license: '1234567', manufacturer: 'xxx', model: 'xxx',
      style: 'SUV', location: 'xxx', status: 'Available'
    ).save
  end

  test 'should have numerical rate' do
    assert_not Car.new(
      license: '1234567', manufacturer: 'xxx', model: 'xxx',
      rate: 'x', style: 'SUV', location: 'xxx', status: 'Available'
    ).save
  end

  test 'should have non-negative rate' do
    assert_not Car.new(
      license: '1234567', manufacturer: 'xxx', model: 'xxx',
      rate: -1, style: 'SUV', location: 'xxx', status: 'Available'
    ).save
  end

  test 'should have style' do
    assert_not Car.new(
      license: '1234567', manufacturer: 'xxx', model: 'xxx',
      rate: 1, location: 'xxx', status: 'Available'
    ).save
  end
end