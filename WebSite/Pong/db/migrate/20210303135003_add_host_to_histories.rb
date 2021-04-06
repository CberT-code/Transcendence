class AddHostToHistories < ActiveRecord::Migration[6.1]
  def change
    add_reference :histories, :host, references: :users
    add_reference :histories, :opponent, references: :users
  end
end
