class AddTimeoutToHistories < ActiveRecord::Migration[6.1]
  def change
	add_column :histories, :timeout, :integer, default: -1
  end
end
