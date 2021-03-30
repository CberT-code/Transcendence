class AddColumnHistoriesIdWar < ActiveRecord::Migration[6.1]
  def change
	add_column :histories, :id_war, :integer, null: false, default: 0
  end
end
