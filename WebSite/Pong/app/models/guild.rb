class Guild < ApplicationRecord
	has_many :user, class_name: 'User', foreign_key: 'guild_id'
	has_many :officers, class_name: 'User'
	has_many :banned, class_name: 'User'
	belongs_to :admin, class_name: 'User', foreign_key: 'id_admin'
	belongs_to :war, class_name: 'War', foreign_key: 'war_id', optional: true
end