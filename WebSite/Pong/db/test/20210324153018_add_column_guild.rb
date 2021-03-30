class AddColumnGuild < ActiveRecord::Migration[6.1]
  def change
	add_column :guilds, :in_war, :boolean, null: false, default: FALSE
  end
end
