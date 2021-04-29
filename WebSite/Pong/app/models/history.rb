class History < ApplicationRecord
	belongs_to	:host, class_name: 'User', foreign_key: 'host_id'
	belongs_to	:opponent, class_name: 'User', foreign_key: 'opponent_id'
	belongs_to	:tournament, class_name: 'Tournament', foreign_key: 'tournament_id'
	belongs_to	:war, foreign_key: 'war_id', optional: true

	def warMatch(loser, winner)
		if loser.guild == self.war.guild1
			self.war.points_guild2 += 1
			if self.opponent_score == -1
				self.war.forfeitedGames1 += 1
			end
		else
			self.war.points_guild1 += 1
			if self.opponent_score == -1
				self.war.forfeitedGames2 += 1
			end
		end
		self.war.save!
	end

	def ladderGame(winner, loser)
		elo = (winner.elo - loser.elo) * (-0.15) + 40.0
		if elo > 70
			elo = 70
		elsif elo < 10
			elo = 10
		end
		winner.elo += elo.to_i
		loser.elo -= elo.to_i
		winner.save!
		loser.save!
		return elo
	end

	def tournamentGame(loser, winner)
		t_winner = winner.t_user.find_by_tournament_id(self.tournament_id)
		t_winner.wins += 1
		t_winner.save!
		t_loser = loser.t_user.find_by_tournament_id(self.tournament_id)
		t_loser.defeats += 1
		t_loser.save!
	end

	def rankedGame(winner, loser)
		elo = 0
		if winner.guild
			winner.guild.points += 10
			if winner.guild.war && winner.guild.war.allow_ext
				if winer.guild.war.guild1 == winner.guild
					winner.guild.war.points_guild1 += 1
				else
					winner.guild.war.points_guild2 += 1
				end
				winner.guild.war.save!
			end
			winner.guild.save!
		end
		if self.tournament_id == 1
			elo = ladderGame(loser, winner)
		else
			tournamentGame(loser, winner)
		end
		return elo
	end

	def end_game_function
		elo = 0
		if self.opponent_score > self.host_score
			loser = self.host
			winner = self.opponent
		else
			loser = self.opponent
			winner = self.host
		end
		if self.statut == 4
			ActionCable.server.broadcast("pong_#{self.id}", {status: "ended", right_pp: self.opponent.image, elo: elo.to_i, winner: winner.id, loser: loser.id, w_name: winner.name})
			return
		end
		self.statut = 4
		self.save!
		if self.war_match
			self.warMatch(loser, winner)
		elsif self.ranked
			elo = self.rankedGame(loser, winner)
		end
		winner.stat.victory += 1
		winner.stat.save!
		loser.stat.defeat += 1
		loser.stat.save!
		ActionCable.server.broadcast("pong_#{self.id}", {status: "ended", right_pp: self.opponent.image, elo: elo.to_i, winner: winner.id, loser: loser.id, w_name: winner.name})
	end
end