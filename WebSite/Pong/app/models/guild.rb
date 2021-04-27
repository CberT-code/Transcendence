class Guild < ApplicationRecord
	has_many :users, class_name: 'User', foreign_key: 'guild_id'
	belongs_to :admin, class_name: 'User', foreign_key: 'id_admin'
	belongs_to :war, class_name: 'War', foreign_key: 'war_id', optional: true
end