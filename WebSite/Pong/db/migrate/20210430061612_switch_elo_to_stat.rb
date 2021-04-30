class SwitchEloToStat < ActiveRecord::Migration[6.1]
  def change
	remove_column :users, :elo, :integer
	add_column :tournament_users, :elo, :integer, default: 1000
  end
end
