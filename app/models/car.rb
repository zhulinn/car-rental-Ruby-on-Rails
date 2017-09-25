class Car < ApplicationRecord
  has_many :records
  validates :license, presence: true, length: { is: 7}, uniqueness: true
  validates :manufacturer, presence: true
  validates :model, presence: true
  validates :rate, presence: true,  numericality: {greater_than_or_equal_to: 0}
  validates :style, presence: true, inclusion: { in: %w(Sedan SUV Coupe),message: "%{value} is not a valid style" }
  validates :location, presence: true
  validates :status, presence: true
end