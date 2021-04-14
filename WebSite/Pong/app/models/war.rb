class War < ApplicationRecord
	belongs_to :tournament, foreign_key: 'tournament_id'
	belongs_to :guild1, class_name: 'Guild', foreign_key: 'guild1_id'
	belongs_to :guild2, class_name: 'Guild', foreign_key: 'guild2_id'
end