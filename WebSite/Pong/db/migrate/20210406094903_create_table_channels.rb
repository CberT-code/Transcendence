class CreateTableChannels < ActiveRecord::Migration[6.1]
  def change
    create_table :channels do |t|
      t.datetime :create_time, null: false
      t.integer :user_id, null: false
      t.string :title, null: false
      t.string :key, null: false
      t.integer :type_channel, null: false
      t.timestamps
    end
  end
end
