class CreateGames < ActiveRecord::Migration[6.1]
	def change
		create_table :games do |t|
			t.string :type_name,				null: false, default: ""
			t.string :description,				null: false, default: ""

			t.timestamps
		end
	end
end
