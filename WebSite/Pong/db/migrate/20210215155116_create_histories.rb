class CreateHistories < ActiveRecord::Migration[6.1]
	def change
		create_table :histories do |t|
			t.integer :tournament_id,		null: false, default: 1

			t.timestamps
		end
	end
end
