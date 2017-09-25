class AddHoursToRecords < ActiveRecord::Migration[5.1]
  def change
    add_column :records, :hours, :integer
  end
end
