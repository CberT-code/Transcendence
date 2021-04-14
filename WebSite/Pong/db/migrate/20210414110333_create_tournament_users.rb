class CreateTournamentUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :tournament_users do |t|
      t.integer :losses, default: 0
      t.integer :wins, default: 0
      t.integer :user_id
      t.integer :tournament_id

      t.timestamps
    end
  end
end
