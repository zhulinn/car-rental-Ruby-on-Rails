class CreateCustomers < ActiveRecord::Migration[5.1]
  def change
    create_table :customers do |t|
      t.string :name
      t.string :email
      t.string :password_digest
      t.integer :charge
      t.integer :record_id

      t.timestamps
    end
  end
end
