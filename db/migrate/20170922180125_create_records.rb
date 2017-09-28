class CreateRecords < ActiveRecord::Migration[5.1]
  def change
    create_table :records do |t|
      t.references :customer, foreign_key: true
      t.references :car, foreign_key: true
      t.timestamp :start
      t.timestamp :end
      t.string :status
      t.integer :hours

      t.timestamps
    end
  end
end
