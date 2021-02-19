class AddOpponentToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :opponent, :integer
  end
end
