class AddBallPosToHistories < ActiveRecord::Migration[6.1]
  def change
	add_column :histories, :ball_x, :integer
	add_column :histories, :ball_y, :integer
  end
end
