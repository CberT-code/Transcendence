class CreateGameType < ActiveRecord::Migration[6.1]
	def change
		create_table :game_types do |t|
			t.string :type_name,				null: false, default: ""
			t.string :description,				null: false, default: ""

			t.timestamps
		end
	end
end
