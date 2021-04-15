class HistoriesController < ApplicationController
	skip_before_action :verify_authenticity_token
	
	before_action do |sign_n_out|
		if !user_signed_in?
			render 'pages/not_authentificate', :status => :unauthorized
		end
	end
	
	def index
		clean_list(-1)
		@me = current_user
		
		hosted = @me.hosted_games.all
		foreign = @me.foreign_games.all
		@games = (hosted + foreign).sort_by { |k| k.updated_at}.reverse!
		@spectate = History.where(statut: 2) #change that after dev
		@date = DateTime.new(1902,1,1,1,1,1);
		@tournament = Tournament.where("(start < ?) OR ('end' > ? AND start < ?)", @date, DateTime.current, DateTime.current);
	end
	
	def show
		clean_list(params[:id].to_i)
		redis = Redis.new(	url:  ENV['REDIS_URL'],
							port: ENV['REDIS_PORT'],
							db:   ENV['REDIS_DB'])
		@me = current_user
		@game = History.find(params[:id])
		if (@game.statut == 3)
			@status = "ended"
			@left = @game.host_score
			@right = @game.opponent_score
		elsif (@game.statut == -1)
			@status = "There was an error with this game"
		else
			@status = redis.get("game_#{@game.id}")
			if @status == nil
				@status = "running"
			end
		end
		ActionCable.server.broadcast("pong_#{@game.id}",
			{status: @status, right_pp: @game.opponent.image})
	end

	def duel
		clean_list(-1)
		redis = Redis.new(	url:  ENV['REDIS_URL'],
							port: ENV['REDIS_PORT'],
							db:   ENV['REDIS_DB'])
		tourn = Tournament.find(params['id'].to_i)
		opponent = User.find(params['opponent'].to_i)
		@me = current_user			
		war_id = params.fetch(:war_id, -1)
		@game = tourn.games.new(statut: 1, host: @me, opponent: opponent,
			host_score: 0, opponent_score: 0, ranked: params[:ranked] == "true" ? true : false,
			war_id: war_id)
		@game.save!
		redis.set("game_#{@game.id}", "ready")
		render html: @game.id
	end

	def find_or_create
		clean_list(-1)
		tourn = Tournament.find(params['id'].to_i)
		if (!tourn)
			render html: "error_tournament"
		else
			redis = Redis.new(url: ENV['REDIS_URL'], port: ENV['REDIS_PORT'], db: ENV['REDIS_DB'])
			@me = current_user
			war_id = params.fetch(:war_id, -1)
			game_found = "no"
			tourn.games.each do |target|
				if target.host != @me && target.statut == 0 &&
						target.ranked == (params[:ranked] == "true") &&
						target.war_id == war_id
					target.opponent = @me
					target.statut = 1
					target.save!
					@game = target
					redis.set("game_#{@game.id}", "ready")
					game_found = "ok"
					ActionCable.server.broadcast("pong_#{@game.id}",
						{status: "ready", right_pp: @game.opponent.image})
					render html: @game.id
					return
				end
			end
			if game_found != "ok"
				@game = tourn.games.new(statut: 0, host: @me, opponent: @me,
					host_score: 0, opponent_score: 0, ranked: params[:ranked] == "true" ? true : false,
					war_id: war_id)
					@game.save!
					redis.set("game_#{@game.id}", "Looking For Opponent")
				render html: @game.id
			end
		end
	end
	
	def run
		@game = History.find(params[:id])
		@game.statut = 2
		@tournament = Tournament.find_by_id(@game.tournament_id);
		if current_user == @game.host # UNCOMMENT THIS LINE OR FACE A SHITSTORM
			redis = Redis.new(	url:  ENV['REDIS_URL'],
								port: ENV['REDIS_PORT'],
								db:   ENV['REDIS_DB'])
			status = "running"
			redis.set("game_#{@game.id}", status)
			frame = 0
			move = Array["static", "static"]
			player = Array[37, 37]
			score = Array[0, 0, 30] # score[2] serves as a countdown
			ball = Array[49, 49, 0.0, @tournament.speed] # [x, y, angle, speed]
			
			while score[0] < @tournament.maxpoints && score[1] < @tournament.maxpoints && status == "running"
				move[1] = redis.get("player_#{@game.opponent.id}")
				move[0] = redis.get("player_#{@game.host.id}")
				time = Time.now
				if score[2] != 0
					score[2] -= 1
				else
					calc(move, player, ball, score, @tournament.speed)
				end
				ActionCable.server.broadcast("pong_#{@game.id}", {	frame: frame, status: status,
																	left_y: "#{player[0]}%", right_y: "#{player[1]}%",
																	ball_x: "#{ball[0]}%", ball_y: "#{ball[1]}%",
																	score: "#{score[0]} - #{score[1]}"})
				while Time.now.to_f <= time.to_f +	0.0417
					sleep 1.0/500.0
				end
				status = redis.get("game_#{@game.id}")
				frame += 1
			end
			if (status == "running")
				@game.statut = 3
			else
				@game.statut = -1
			end
			@game.host_score = score[0]
			@game.opponent_score = score[1]
			@game.save!
			redis.del("game_#{@game.id}")
			end_game_function(@game)
			render html: "score: #{score[0]} - #{score[1]} - #{"ended"} - #{@game.statut}"
		end # UNCOMMENT THIS LINE OR FACE A SHITSTORM
	end
	
	
	def calc(move, player, ball, score, speed)
		for i in 0..1
			if move[i] == "up"
				player[i] += 3
			elsif move[i] == "down"
				player[i] -= 3
			end
			if player[i] <= 0
				player[i] = 0
			elsif player[i] >= 75
				player[i] = 75
			end
		end
		move_ball(move, ball, score, player, speed)
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
				#add effect according to speed
				if move[0] == "up"
					ball[2] += 0.2
				elsif move[0] == "down"
					ball[2] -= 0.2
				end
			else
				score[1] += 1
				reset(player, ball, score, speed)
				return
			end
		elsif ball[0] >= 96.6
			if ball[1].to_i - player[1] <= 25 && ball[1].to_i - player[1] >= 0
				ball[2] = (pi - ball[2] + tpi) % tpi
				ball[3] *= 1.02
				ball[0] = 193.2 - ball[0]
				#add effect according to speed
				if move[1] == "up"
					ball[2] -= 0.2
				elsif move[0] == "down"
					ball[2] += 0.2
				end
			else
				score[0] += 1
				reset(player, ball, score, speed)
				return
			end
		end
		if ball[1] <= 0.0
			ball[2] = (ball[2] * -1 + tpi) % tpi
		elsif ball[1] >= 98.25
			ball[2] = (tpi - ball[2]) % tpi
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
	
	def stop
		redis = Redis.new(	url:  ENV['REDIS_URL'],
							port: ENV['REDIS_PORT'],
							db:   ENV['REDIS_DB'])
		redis.set("game_#{params[:id]}", "ended")
	end

	def end_game_function(game)
		elo = 0
		if (game.opponent_score > game.host_score)
			loser = game.host
			winner = game.opponent
		else
			winner = game.host
			loser = game.opponent
		end
		if game.ranked
			if game.war_id == winner.guild.war_id
				end_of_war_game(winner.guild, game.war_id)
			elsif (game.tournament_id != 1)
				end_of_tournament_game(TournamentUser.find_by_user_id(winner.id), TournamentUser.find_by_user_id(loser.id))
			else
			# regular ranked
				elo = (winner.elo - loser.elo) * (-0.15) + 40.0
				winner.elo += elo
				loser.elo -= elo
				winner.save!
				loser.save!
			end
		end
		ActionCable.server.broadcast("pong_#{game.id}", {status: "ended", elo: elo, winner: winner.id, loser: loser.id, w_name: winner.name})
	end

	def end_of_war_game(w_guild, war)
		if w_guild.id == war.guild1_id
			war.points_guild1 += 1
		else
			war.points_guild2 += 1
		end
	end

	def end_of_tournament_game(t_winner, t_loser)
		t_winner.wins += 1
		t_loser.losses += 1
		t_winner.save
		t_loser.save
	end

	def clean_list(id)
		History.all.each do |game|
			if (game.host == game.opponent && game.host == current_user && game.id != id) ||
				game.statut == -1
				ActionCable.server.broadcast("pong_#{game.id}", {status: "deleted"})
				game.destroy
			end
		end
	end
	
	def create
	end
	
	def delete
	end
end
