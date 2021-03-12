class AddBallDirToHistories < ActiveRecord::Migration[6.1]
  def change
    add_column :histories, :ball_x_dir, :integer
    add_column :histories, :ball_y_dir, :integer
  end
end
