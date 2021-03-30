class AddDetailsToGuilds < ActiveRecord::Migration[6.1]
  def change
    add_column :guilds, :maxmember, :integer
    add_column :guilds, :nbmember, :integer
  end
end
