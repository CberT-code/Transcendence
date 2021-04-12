class AddColumnToTournaments < ActiveRecord::Migration[6.1]
  def change
	add_column :tournaments, :maxpoints, :integer
	add_column :tournaments, :speed, :float
  end
end
