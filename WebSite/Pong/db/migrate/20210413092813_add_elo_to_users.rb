class AddEloToUsers < ActiveRecord::Migration[6.1]
  def change
	add_column :users, :elo, :integer, default: 1000
  end
end
