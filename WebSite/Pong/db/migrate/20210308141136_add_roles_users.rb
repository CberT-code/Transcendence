class AddRolesUsers < ActiveRecord::Migration[6.1]
  def change
	add_column :users, :role, :integer
    add_column :users, :guild_role, :integer
  end
end
