class AddTournamentTimeToTournament < ActiveRecord::Migration[6.1]
  def change
	add_column :tournaments, :status, :integer, default: 0
  end
end
