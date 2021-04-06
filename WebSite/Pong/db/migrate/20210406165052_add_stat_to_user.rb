class AddStatToUser < ActiveRecord::Migration[6.1]
  def change
    add_reference :users, :stat, null: false, foreign_key: true
  end
end
