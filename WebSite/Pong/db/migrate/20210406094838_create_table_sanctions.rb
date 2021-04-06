class CreateTableSanctions < ActiveRecord::Migration[6.1]
  def change
    create_table :sanctions do |t|
      t.datetime :create_time, null: false
      t.integer :end_time, null: false
      t.integer :user_id, null: false
      t.integer :sanction_type, null: false
      t.integer :target_id, null: false
      t.timestamps
    end
  end
end
