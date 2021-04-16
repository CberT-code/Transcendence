class AdDiffToTUser < ActiveRecord::Migration[6.1]
  def change
	add_column :tournament_users, :difference, :integer, :default => 0
  end
end
