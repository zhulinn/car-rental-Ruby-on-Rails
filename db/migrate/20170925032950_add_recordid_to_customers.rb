class AddRecordidToCustomers < ActiveRecord::Migration[5.1]
  def change
    add_column :customers, :recordid, :integer
  end
end
