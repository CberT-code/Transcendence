class Tournament < ApplicationRecord
	has_many :games, class_name: 'History', foreign_key: 'tournament_id'
	has_many :t_users, class_name: 'TournamentUser', foreign_key: 'tournament_id'

	def self.isAvailable(id)
		tr = Tournament.find_by_id(id)
		if !tr
			return false
		end
		return tr.available()
	end

	def available
		if self.status == 1
			return true
		end
		return false
	end

	def self.tUserExists(tournament_id, user_id)
		tr = Tournament.find_by_id(tournament_id)
		user = User.find_by_id(user_id)
		if !tr || !user
			return false
		end
		return tr.playerIsRegistered(user_id)
	end

	def playerIsRegistered(id)
		if self.t_users.find_by_user_id(id) == nil
			return false
		end
		return true
	end

	def self.statustournament
		tournamentsend = Tournament.where({status: 1}).where.not({end: nil})
		tournamentsend.each do |tournament|
			time = Time.now - tournament.end
			if (time >= 0)
				t_user = TournamentUser.where(["tournament_id = ?", tournament.id]).sort_by { |u| [u.elo]}.reverse.first
				if (t_user)
					stat = Stat.find_by_id(t_user.user.stat_id)
					stat.update({tournament: stat.tournament + 1})
					stat.save
				end
					tournament.update({status: 2})
			end
		end
		@tournamentsstart = Tournament.where(["status = ? AND CAST(\"start\" AS DATE) = ? ", 0, DateTime.now.to_date])
		@tournamentsstart.each do |tournament|
			tournament.update({status: 1})
		end
		tournamentdel = Tournament.where(["status = ?", 2])
		tournamentdel.each do |tournament|
			if tournament.end + 7 * 60 * 60 * 24 < Time.now
				tournament.delete
			end
		end
	end
end