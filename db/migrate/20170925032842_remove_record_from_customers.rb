class RemoveRecordFromCustomers < ActiveRecord::Migration[5.1]
  def change
    remove_reference :customers, :record, foreign_key: true
  end
end
