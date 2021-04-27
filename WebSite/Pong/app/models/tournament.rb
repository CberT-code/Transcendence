class Tournament < ApplicationRecord
	has_many :games, class_name: 'History', foreign_key: 'tournament_id'
	has_many :t_users, class_name: 'TournamentUser', foreign_key: 'tournament_id'

	def available
		if !self.end || !self.start || (self.start < Time.now && Time.now < self.end)
			return true
		end
		return false
	end

	def playerIsRegistered(id)
		if self.t_users.find_by_user_id(id) == nil
			return false
		end
		return true
	end
end