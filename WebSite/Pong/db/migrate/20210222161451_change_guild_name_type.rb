class ChangeGuildNameType < ActiveRecord::Migration[6.1]
  def change
	change_column :guilds, :name, :citext, unique: true
  end
end
