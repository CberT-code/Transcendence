class AddSpecsToWar < ActiveRecord::Migration[6.1]
  def change
	add_column :wars, :timeout, :integer, default: 30
	add_column :wars, :allow_ext, :boolean, default: true
	add_column :wars, :forfeitedGames1, :integer, default: 5
	add_column :wars, :forfeitedGames2, :integer, default: 5
	add_column :wars, :ongoingMatch, :boolean, default: false
  end
end
