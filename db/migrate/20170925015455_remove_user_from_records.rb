class RemoveUserFromRecords < ActiveRecord::Migration[5.1]
  def change
    remove_reference :records, :user, foreign_key: true
  end
end
