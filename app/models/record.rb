class Record < ApplicationRecord
  belongs_to :car
  belongs_to :customer
  def update_start(start_time)
    update_attribute(:start, start_time)
  end

  def update_end(end_time)
    update_attribute(:end, end_time)
  end

  def update_status(status)
    update_attribute(:status, status)
  end

  def update_hours(hours)
    update_attribute(:hours, hours)
  end
end
