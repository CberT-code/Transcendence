class CreateGames < ActiveRecord::Migration[6.1]
  def change
    create_table :games do |t|
      t.references :user
      t.string :status
      t.string :type

      t.timestamps
    end
  end
end
