class TournamentUser < ApplicationRecord
	belongs_to :tournament, class_name: 'Tournament', foreign_key: 'tournament_id'
	belongs_to :user, class_name: 'User', foreign_key: 'user_id'
end
