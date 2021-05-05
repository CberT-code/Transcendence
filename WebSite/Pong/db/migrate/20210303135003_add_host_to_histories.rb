class AddHostToHistories < ActiveRecord::Migration[6.1]
  def change
    add_reference :histories, :host, references: :users
    add_reference :histories, :opponent, optional: true, references: :users
	add_column :histories, :host_ready, :boolean, default: false
	add_column :histories, :opponent_ready, :boolean, default: false
  end
end
