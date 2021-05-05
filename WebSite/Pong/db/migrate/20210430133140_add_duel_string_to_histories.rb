class AddDuelStringToHistories < ActiveRecord::Migration[6.1]
  def change
	add_column :histories, :duel, :boolean, default: false
  end
end
