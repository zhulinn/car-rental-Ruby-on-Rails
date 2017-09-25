class AddCustomerToRecords < ActiveRecord::Migration[5.1]
  def change
    add_reference :records, :customer, foreign_key: true
  end
end
