class History < ApplicationRecord
	belongs_to	:host, class_name: 'User', foreign_key: 'host_id'
	belongs_to	:opponent, class_name: 'User', foreign_key: 'opponent_id', optional: true
	belongs_to	:tournament, class_name: 'Tournament', foreign_key: 'tournament_id'
	belongs_to	:war, foreign_key: 'war_id', optional: true

	
	def wait
		redis = Redis.new(url: ENV['REDIS_URL'], port: ENV['REDIS_PORT'], db: ENV['REDIS_DB'])
		waiting = Array["    *", ".   *", "..  *", "... *"]
		frame = 0
		while self.timeout != 0 && redis.get("game_#{self.id}") == "Waiting for opponent"
			puts "game #{self.id} waiting"
			time = Time.now
			ActionCable.server.broadcast("pong_#{self.id}", {status: "waiting",
				score: "* Waiting for opponent #{waiting[frame % 4]}"})
			while Time.now.to_f <= time.to_f + 1
				sleep 1.0/200.0
			end
			if self.timeout != -1
				self.timeout -= 1
			end
			frame += 1
		end
		if timeout == 0
			puts "game timed out!"
			if self.war_match
				self.update(opponent: self.host.guild.enemy_guild().admin,
					opponnent_score: -1, statut: 3)
			else
				self.update(statut: -1)
			end
			self.endGame()
		end
	end

	def run
		frame = 0
		move = Array["static", "static"]
		player = Array[37, 37]
		score = Array[0, 0, 30] # score[2] serves as a countdown
		ball = Array[49, 49, 0.0, self.tournament.speed] # [x, y, angle, speed]
		if self.host != self.opponent
			ActionCable.server.broadcast("pong_#{self.id}", {status: "ready",
			right_pp: self.opponent.image,
			left_pp: self.host.image})
		else
			ActionCable.server.broadcast("pong_#{self.id}", {status: "ready",
			right_pp: "https://pbs.twimg.com/profile_images/2836953017/11dca622408bf418ba5f88ccff49fce1.jpeg",
			left_pp: "https://pbs.twimg.com/profile_images/2836953017/11dca622408bf418ba5f88ccff49fce1.jpeg"})
		end
		status = "running"
		redis = Redis.new(url: ENV['REDIS_URL'], port: ENV['REDIS_PORT'], db: ENV['REDIS_DB'])
		while score[0] < self.tournament.maxpoints && score[1] < self.tournament.maxpoints && status == "running"
			move[1] = redis.get("player_#{self.opponent.id}")
			move[0] = redis.get("player_#{self.host.id}")
			time = Time.now
			if score[2] != 0
				score[2] -= 1
			else
				self.calc(move, player, ball, score, self.tournament.speed)
			end
			ActionCable.server.broadcast("pong_#{self.id}", {
				frame: frame, status: status, left_y: "#{player[0]}%", right_y: "#{player[1]}%",
				ball_x: "#{ball[0]}%", ball_y: "#{ball[1]}%",
				score: "#{score[0]} - #{score[1]}" })
			while Time.now.to_f <= time.to_f +	0.0417
				sleep 1.0/500.0
			end
			frame += 1
			if self.opponent.isOnline() == "offline" && self.host.isOnline() == "offline"
				status = "disconnect"
			else
				status = redis.get("game_#{self.id}")
			end
		end
		if status == "running" && self.opponent && self.opponent != self.host
			self.update(statut: 3)
		else
			self.update(statut: -1)
		end
		self.endGame()
	end

	def calc(move, player, ball, score, speed)
		for i in 0..1
			if move[i] == "up"
				player[i] += 4
			elsif move[i] == "down"
				player[i] -= 4
			end
			if player[i] <= 0
				player[i] = 0
			elsif player[i] >= 75
				player[i] = 75
			end
		end
		self.move_ball(move, ball, score, player, speed)
	end
	
	def move_ball(move, ball, score, player, speed)
		ball[0] += Math.cos(ball[2]) * ball[3]
		ball[1] += Math.sin(ball[2]) * ball[3]
		pi = Math::PI
		tpi = 2 * pi
		if ball[0] <= 2
			if ball[1].to_i - player[0] <= 25 && ball[1].to_i - player[0] >= 0
				ball[2] = (pi - ball[2] + tpi) % tpi
				ball[3] *= 1.02
				ball[0] = ball[0] * -1 + 2
				if move[0] == "up" && player[0] > 0
					ball[2] += 0.2
				elsif move[0] == "down" && player[0] < 75
					ball[2] -= 0.2
				end
			else
				score[1] += 1
				self.reset(player, ball, score, speed)
				return
			end
		elsif ball[0] >= 96.6
			if ball[1].to_i - player[1] <= 25 && ball[1].to_i - player[1] >= 0
				ball[2] = (pi - ball[2] + tpi) % tpi
				ball[3] *= 1.02
				ball[0] = 193.2 - ball[0]
				if move[1] == "up" && player[1] > 0
					ball[2] -= 0.2
				elsif move[1] == "down" && player[1] < 75
					ball[2] += 0.2
				end
			else
				score[0] += 1
				self.reset(player, ball, score, speed)
				return
			end
		end
		if ball[1] <= 0.0
			ball[2] = (ball[2] * -1 + tpi) % tpi
		elsif ball[1] >= 98.25
			ball[2] = (tpi - ball[2]) % tpi
		end
		if ball[3] > 80
			ball[3] = 80
		end
	end
	
	def reset(player, ball, score, speed)
		ball[0] = 49.25
		ball[1] = 49.4
		ball[3] = speed
		player[0] = 37
		player[1] = 37
		score[2] = 30
	end

	def endGame
		redis = Redis.new(url: ENV['REDIS_URL'], port: ENV['REDIS_PORT'], db: ENV['REDIS_DB'])
		self.host_score = score[0]
		self.opponent_score = score[1]
		self.save!
		redis.set("player_#{self.host_id}", "online")
		redis.set("player_#{self.opponent_id}", "online")
		redis.del("game_#{self.id}")
		elo = 0
		if self.statut == 3
			if self.opponent_score > self.host_score
				loser = self.host
				winner = self.opponent
			else
				loser = self.opponent
				winner = self.host
			end
			if self.war_match
				self.warMatch(loser, winner)
			elsif self.ranked
				elo = self.rankedGame(loser, winner)
			end
			winner.stat.victory += 1
			winner.stat.save!
			loser.stat.defeat += 1
			loser.stat.save!
		else
			winner = self.host
			loser = self.host
		end
		ActionCable.server.broadcast("pong_#{self.id}", {status: "ended",
			elo: elo.to_i, winner: winner.id,
			loser: loser.id, w_name: winner.name})
	end
		
	def warMatch(loser, winner)
		if loser.guild == self.war.guild1
			self.war.points_guild2 += 1
			if self.opponent_score == -1
				self.war.forfeitedGames1 -= 1
				if self.war.forfeitedGames1 == 0
					#end war
				end
			end
		else
			self.war.points_guild1 += 1
			if self.opponent_score == -1
				self.war.forfeitedGames2 -= 1
				if self.war.forfeitedGames2 == 0
					#end war
				end
			end
		end
		self.war.save!
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
		elo = ladderGame(winner, loser)
		return elo
	end

	def ladderGame(winner, loser)
		elo = (winner.elo - loser.elo) * (-0.15) + 40.0
		if elo > 70
			elo = 70
		elsif elo < 10
			elo = 10
		end
		t_winner = winner.t_user.find_by_tournament_id(self.tournament_id)
		t_winner.wins += 1
		t_winner.elo += elo.to_i
		t_winner.save!
		t_loser = loser.t_user.find_by_tournament_id(self.tournament_id)
		t_loser.defeats += 1
		t_loser.elo -= elo.to_i
		t_loser.save!
		return elo
	end
end