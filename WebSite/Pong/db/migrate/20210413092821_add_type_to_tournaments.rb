class AddTypeToTournaments < ActiveRecord::Migration[6.1]
  def change
	add_column :tournaments, :tournament_type, :string
end
end
