class CreateTournaments < ActiveRecord::Migration[6.1]
	def change
		create_table :tournaments do |t|
			t.string :name,					null: false, default: ""
			t.string :description,			null: false, default: ""
			t.datetime :start,				null: true
			t.datetime :end,				null: true

			t.timestamps
		end
	end
end
