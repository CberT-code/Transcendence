class AddRankedBoolToHistories < ActiveRecord::Migration[6.1]
  def change
	add_column :histories, :ranked, :bool
  end
end
