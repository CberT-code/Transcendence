class AddWarToHistory < ActiveRecord::Migration[6.1]
  def change
    add_reference :histories, :war, null: true, foreign_key: true
  end
end
