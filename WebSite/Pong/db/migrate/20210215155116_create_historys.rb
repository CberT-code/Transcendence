class CreateHistorys < ActiveRecord::Migration[6.1]
	def change
		create_table :historys do |t|
			t.integer :target_type,			null: false, default: -1
			t.integer :target_1,			null: false, default: -1
			t.integer :target_2,			null: false, default: -1
			t.integer :score_target_1,		null: false, default: 0
			t.integer :score_target_2,		null: false, default: 0
			t.datetime :start
			t.datetime :end
			t.integer :id_type,				null: false, default: -1

			t.timestamps
		end
	end
end
