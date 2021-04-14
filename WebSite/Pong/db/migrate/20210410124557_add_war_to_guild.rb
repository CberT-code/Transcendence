class AddWarToGuild < ActiveRecord::Migration[6.1]
  def change
    add_reference :guilds, :war, null: true
  end
end
