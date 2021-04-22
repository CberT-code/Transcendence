class AddWarStatusToHistories < ActiveRecord::Migration[6.1]
  def change
	add_column :histories, :war_match, :bool, default: false
  end
end
