class AddTournamentToWar < ActiveRecord::Migration[6.1]
  def change
    add_reference :wars, :tournament, null: false, foreign_key: true
  end
end
