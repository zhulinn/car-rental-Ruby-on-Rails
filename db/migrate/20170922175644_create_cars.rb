class CreateCars < ActiveRecord::Migration[5.1]
  def change
    create_table :cars do |t|
      t.string :license
      t.string :manufacturer
      t.string :model
      t.integer :rate
      t.string :style
      t.string :location
      t.string :status

      t.timestamps
    end
  end
end
