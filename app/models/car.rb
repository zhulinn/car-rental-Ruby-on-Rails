class Car < ApplicationRecord
  has_many :records, dependent: :destroy
  validates :license,
            presence: true,
            format: { with: /\A\d{7}\z/ },
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
              in: ['Available', 'Reserved', 'Checked Out'],
              message: '%<value>s is not a valid status'
            }

  def update_status(status)
    update_attribute(:status, status)
  end
end