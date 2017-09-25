class AddRecordToCustomers < ActiveRecord::Migration[5.1]
  def change
    add_reference :customers, :record, foreign_key: true
  end
end
