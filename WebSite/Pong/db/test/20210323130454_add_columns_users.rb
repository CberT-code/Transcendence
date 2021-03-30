class AddColumnsUsers < ActiveRecord::Migration[6.1]
  def change
	add_column :users, :points, :integer, null: false, default: 0
	add_column :users, :available, :boolean, null: false, default: FALSE
  end
end
