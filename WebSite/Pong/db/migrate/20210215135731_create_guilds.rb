class CreateGuilds < ActiveRecord::Migration[6.1]
	def change
		create_table :guilds do |t|
			t.string :name,				null: false, unique: true, default: ""
			t.string :anagramme,		null: false, unique: true, default: ""
			t.string :description,		null: false, default: ""
			t.integer :points,			null: false, default: 0
			t.integer :id_stats,		null: false, default: -1
			t.integer :maxmember,		null: false, default: 5
			t.integer :nbmember,		null: false, default: 0
			t.integer :id_admin,		null: false
			t.integer :officers,		array: true, default: []
			t.integer :banned,			array: true, default: []
			t.boolean :deleted,			null: false, default: FALSE
			t.integer :officers,		array: true, default: []
			t.integer :banned,			array: true, default: []
			
			t.datetime :creation

			t.timestamps
		end
	end
end
