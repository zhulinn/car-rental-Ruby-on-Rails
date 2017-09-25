class CreateRecords < ActiveRecord::Migration[5.1]
  def change
    create_table :records do |t|
      t.references :car, foreign_key: true
      t.references :user, foreign_key: true
      t.timestamp :start
      t.timestamp :end

      t.timestamps
    end
  end
end
