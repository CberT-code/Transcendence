class AddBannedToUser < ActiveRecord::Migration[6.1]
  def change
	add_column :users, :banned, :bool, default: false
  end
end
