class AddColumnPoint < ActiveRecord::Migration[6.1]
  def change
	add_column :histories, :points, :integer, null: false, default: 0
  end
end
