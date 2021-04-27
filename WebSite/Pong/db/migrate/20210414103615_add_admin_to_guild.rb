class AddAdminToGuild < ActiveRecord::Migration[6.1]
  def change
    add_reference :guilds, :admin, references: :users
  end
end
