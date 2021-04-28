class Tournament < ApplicationRecord
	has_many :games, class_name: 'History', foreign_key: 'tournament_id'
	has_many :t_users, class_name: 'TournamentUser', foreign_key: 'tournament_id'

	def self.statustournament
		tournamentsend = Tournament.where("status = ? AND CAST(\"end\" AS DATE) = ? ", 1, DateTime.now.to_date);
		tournamentsend.each do |tournament|
			time = Time.now - tournament.end
			puts "end"
			if (time > 0)
				tournament.update(status: 2)
				tournament.delete
			end
		end
		@tournamentsstart = Tournament.where("status = ? AND CAST(\"start\" AS DATE) = ? ", 0, DateTime.now.to_date);
		@tournamentsstart.each do |tournament|
			puts "start"
			tournament.update(status: 1)
		end
	end
end