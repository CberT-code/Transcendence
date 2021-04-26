class War < ApplicationRecord
	belongs_to :tournament, foreign_key: 'tournament_id'
	belongs_to :guild1, class_name: 'Guild', foreign_key: 'guild1_id'
	belongs_to :guild2, class_name: 'Guild', foreign_key: 'guild2_id'
	has_many :games, class_name: 'History', foreign_key: 'war_id'

	def isWarTime
		# TO DO
		return true
	end
	def self.teste
		puts "GROSSE BITE"
	end
end