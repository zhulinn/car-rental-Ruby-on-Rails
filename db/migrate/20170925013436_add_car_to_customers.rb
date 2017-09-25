class AddCarToCustomers < ActiveRecord::Migration[5.1]
  def change
    add_reference :customers, :car, foreign_key: true
  end
end
