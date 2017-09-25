class RemoveCarFromCustomers < ActiveRecord::Migration[5.1]
  def change
    remove_reference :customers, :car, foreign_key: true
  end
end
