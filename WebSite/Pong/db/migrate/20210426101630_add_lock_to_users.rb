class AddLockToUsers < ActiveRecord::Migration[6.1]
  def change
	add_column :users, :locked, :boolean, default: false
  end
end
