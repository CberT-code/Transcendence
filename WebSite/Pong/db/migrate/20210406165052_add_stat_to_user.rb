class AddStatToUser < ActiveRecord::Migration[6.1]
  def change
    add_reference :users, :stat, null: true, foreign_key: true
  end
end
