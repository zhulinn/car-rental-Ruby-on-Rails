class CreateCustomers < ActiveRecord::Migration[5.1]
  def change
    create_table :customers do |t|
      t.string :name
      t.string :email
      t.string :password_digest
      t.integer :charge
      t.string :status
      t.integer :record_id
      t.integer :car_id
      t.string :job_id
      t.integer :subscribe_car_id


      t.timestamps
    end
  end
end
