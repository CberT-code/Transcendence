class CreateTableMessages < ActiveRecord::Migration[6.1]
  def change
    create_table :messages do |t|
      t.datetime :create_time, null: false
      t.integer :user_id, null: false
      t.integer :message_type, null: false
      t.string :message, null: false
      t.integer :target_id, null: false
      t.timestamps
    end
  end
end
