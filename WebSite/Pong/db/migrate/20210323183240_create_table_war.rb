class CreateTableWar < ActiveRecord::Migration[6.1]
  def change
    create_table :wars do |t|
		t.integer :guild1_id,		null: false
		t.integer :team1,			array: true, default: []
		t.integer :points_guild1,	null: false, default: 0
		t.integer :guild2_id,		null: false
		t.integer :team2,			array: true, default: []
		t.integer :points_guild2,	null: false, default: 0
		t.datetime :start
		t.datetime :end
		t.integer :points,		null: false
		t.integer :players,		null: false
		t.integer :status,		null: false, default: 0
    end
  end
end
