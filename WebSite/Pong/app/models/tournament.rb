class Tournament < ApplicationRecord
	has_many :games, class_name: 'History', foreign_key: 'game_id'

end