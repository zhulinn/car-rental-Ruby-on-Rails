class Car < ApplicationRecord
  before_save {
    self.manufacturer = manufacturer.downcase
    self.model = model.downcase
    self.location = location.downcase
  }
  has_many :records, dependent: :destroy
  validates :license,
            presence: true,
            length: { is: 7},
            uniqueness: true
  validates :manufacturer, presence: true
  validates :model, presence: true
  validates :rate, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :style,
            presence: true,
            inclusion: {
              in: %w[Sedan SUV Coupe],
              message: '%<value>s is not a valid style'
            }
  validates :location, presence: true
  validates :status,
            presence: true,
            inclusion: {
              in: ['Available', 'Reserved', 'Checked Out', 'Suggested'],
              message: '%<value>s is not a valid status'
            }

  def update_status(status)
    update_attribute(:status, status)
  end
  
  def update_customer_id(id)
    update_attribute(:customer_id, id)
  end
end