class CreateGuilds < ActiveRecord::Migration[6.1]
	def change
		create_table :guilds do |t|
			t.string :name,				null: false, default: ""
			t.string :description,		null: false, default: ""
			t.datetime :creation
			t.integer :id_stats,		null: false, default: -1

			t.timestamps
		end
	end
end
