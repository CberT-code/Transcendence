class AddWarToHistories < ActiveRecord::Migration[6.1]
  def change
    add_reference :histories, :war, references: :wars
  end
end
