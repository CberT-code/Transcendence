class AddWarTimeToWars < ActiveRecord::Migration[6.1]
  def change
	add_column :wars, :wartime, :bool, default: false
  end
end
