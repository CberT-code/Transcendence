class CreateGuilds < ActiveRecord::Migration[6.1]
	def change
		create_table :guilds do |t|
			t.string :name,				null: false, default: ""
			t.string :description,		null: false, default: ""
			t.integer :points,			null: false, default: 0
			t.datetime :creation
			t.integer :id_stats,		null: false, default: -1
			t.integer :maxmember,		null: false, default: -1
			t.integer :nbmember,		null: false, default: -1
			t.integer :id_admin,		null: false, default: 0
			t.boolean :available,		null: false, default: FALSE
			t.boolean :in_war,			null: false, default: FALSE
			t.integer :status,			null: false, default: 0

			t.timestamps
		end
	end
end
