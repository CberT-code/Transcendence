class ChangeNicknameType < ActiveRecord::Migration[6.1]
  def change
	enable_extension :citext
	change_column :users, :nickname, :citext, unique: true
  end
end
