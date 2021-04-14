class AddColumnFriendsToUsers < ActiveRecord::Migration[6.1]
  def change
	add_column :users, :friends, :integer, array: true, default: []
  end
end
