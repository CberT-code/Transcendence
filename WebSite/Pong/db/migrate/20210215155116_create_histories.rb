class CreateHistories < ActiveRecord::Migration[6.1]
	def change
		create_table :histories do |t|
			t.integer :id_tournament,		null: false, default: 1
			t.integer :id_war,				null: false, default: 0
			t.integer :target_1,			null: false
			t.integer :score_target_1,		null: false, default: 0
			t.integer :target_2,			null: false
			t.integer :score_target_2,		null: false, default: 0
			t.integer :points,				null: false
			t.datetime :start,              null: true
			t.datetime :end,                null: true

			t.timestamps
		end
	end
end
