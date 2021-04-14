class AddGuildsToWar < ActiveRecord::Migration[6.1]
  def change
    add_reference :guilds, :guild1, references: :guilds
    add_reference :guilds, :guild2, references: :guilds
end
end
