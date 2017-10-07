class Customer < ApplicationRecord
  has_many :records, dependent: :destroy
  before_save { self.email = email.downcase }
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email,
            presence: true,
            length: { maximum: 255 },
            format: { with: VALID_EMAIL_REGEX },
            uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password,
            presence: true,
            length: { minimum: 6 },
            unless: :password_skip?
  def password_skip?
    @password_skip
  end

  def password_need
    @password_skip = false
  end

  def password_no_deed
    @password_skip = true
  end

  def update_charge(charge)
    update_attribute(:charge, charge)
  end

  def update_status(status)
    update_attribute(:status, status)
  end

  def update_record_id(record_id)
    update_attribute(:record_id, record_id)
  end

  def update_car_id(car_id)
    update_attribute(:car_id, car_id)
  end
  def update_subscribe_car_id(car_id)
    update_attribute(:subscribe_car_id, car_id)
  end
end
