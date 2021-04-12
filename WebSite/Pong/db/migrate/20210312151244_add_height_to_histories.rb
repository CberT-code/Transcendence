class AddHeightToHistories < ActiveRecord::Migration[6.1]
  def change
	  add_column :histories, :host_height, :integer
	  add_column :histories, :oppo_height, :integer
  end
end
