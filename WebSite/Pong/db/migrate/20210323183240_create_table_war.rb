class CreateTableWar < ActiveRecord::Migration[6.1]
  def change
    create_table :wars do |t|
		t.integer :id_guild1,		null: false, default: -1
		t.integer :team1,			array: true, default: []
		t.integer :points_guild1,	null: false, default: -1
		t.integer :id_guild2,		null: false, default: -1
		t.integer :team2,			array: true, default: []
		t.integer :points_guild2,	null: false, default: -1
		t.datetime :start
		t.datetime :end
		t.integer :points,		null: false, default: -1
		t.integer :players,		null: false, default: -1
		t.integer :status,		null: false, default: -1
    end
  end
end