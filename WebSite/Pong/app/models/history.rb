class History < ApplicationRecord
	belongs_to	:host, class_name: 'User', foreign_key: 'host_id'
	belongs_to	:opponent, class_name: 'User', foreign_key: 'opponent_id'
	belongs_to	:tournament, class_name: 'Tournament', foreign_key: 'tournament_id'
	belongs_to	:war, foreign_key: 'war_id', optional: true
end