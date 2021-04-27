class AddScoreToHistory < ActiveRecord::Migration[6.1]
  def change
    add_column :histories, :host_score, :integer, default: 0
    add_column :histories, :opponent_score, :integer, default: 0
  end
end
