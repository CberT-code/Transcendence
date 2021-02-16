class CreateStats < ActiveRecord::Migration[6.1]
	def change
		create_table :stats do |t|
			t.integer :victory,			null: false, default: 0
			t.integer :defeat,			null: false, default: 0
			t.integer :tournament,		null: false, default: 0

			t.timestamps
		end
	add_index :stats, :victory,                unique: false
	end
end
