class AddIdAdmninToGuilds < ActiveRecord::Migration[6.1]
  def change
	add_column :guilds, :id_admin, :integer
  end
end
