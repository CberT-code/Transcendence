class AddGuildToUser < ActiveRecord::Migration[6.1]
  def change
	add_reference :users, :guild, null: true, foreign_key: true
  end
end
