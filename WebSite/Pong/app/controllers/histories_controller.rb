class HistoriesController < ApplicationController
	skip_before_action :verify_authenticity_token
	
	before_action do |sign_n_out|
		if !user_signed_in?
			render 'pages/not_authentificate', :status => :unauthorized
		end
	end
		
	def index
		clean_list
		@me = current_user
		
		hosted = @me.hosted_games.all
		foreign = @me.foreign_games.all
		@games = (hosted + foreign).sort_by { |k| k.updated_at}.reverse!
		@spectate = @games #change that after dev
	end
	
	def show
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
		end
	end

	def find_or_create
		tourn = Tournament.find_by_name(params['name'])
		if (!tourn)
			render html: "error_tournament"
		else
			redis = Redis.new(	url:  ENV['REDIS_URL'],
								port: ENV['REDIS_PORT'],
								db:   ENV['REDIS_DB'])
			@me = current_user
			game_found = "no"
			History.all.each do |target|
				if target.host != @me && target.statut == 0 && target.tournament_id == @tournament
					@game = target
					@game.opponent = @me
					redis.set("game_#{@game.id}", "ready")
					@game.save!
					game_found = "ok"
					ActionCable.server.broadcast("pong_#{@game.id}", {body: "what is my purpose again?", status: "ready", right_pp: @game.opponent.image})
					render html: @game.id
					return
				end
			end
			if game_found != "ok"
				@game = @me.hosted_games.new(statut: 0, opponent: @me, host_height: 150, oppo_height: 150,
					ball_x: 245, ball_y: 195, ball_x_dir: 1, ball_y_dir: 1, host_score: 0, opponent_score: 0, tournament_id: @tournament)
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
		if current_user == @game.host
			redis = Redis.new(	url:  ENV['REDIS_URL'],
								port: ENV['REDIS_PORT'],
								db:   ENV['REDIS_DB'])
			status = "running"
			redis.set("game_#{@game.id}", status)
			frame = 0
			move = Array["static", "static"]
			player = Array[75, 75]
			score = Array[0, 0, 30] # score[2] serves as a countdown
			ball = Array[245.0, 195.0, 4.0, @tournament.speed] # [x, y, angle, speed]
			
			while score[0] < @tournament.maxpoints && score[1] < @tournament.maxpoints && status == "running"
				move[1] = redis.get("player_#{@game.opponent.id}")
				move[0] = redis.get("player_#{@game.host.id}")
				time = Time.now
				if score[2] != 0
					score[2] -= 1
				else
					calc(move, player, ball, score, @tournament.speed)
				end
				ActionCable.server.broadcast("pong_#{@game.id}", {	body: "Left : #{move[0]} -- Right : #{move[0]}",
																	frame: frame, status: status,
																	left_y: player[0], right_y: player[1],
																	ball_x: ball[0], ball_y: ball[1],
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
			@game.save
			status = "ended"
			ActionCable.server.broadcast("pong_#{@game.id}",
				{ body: "Left : #{move[0]} -- Right : #{move[1]}", status: status})
			redis.del("game_#{@game.id}")
		end
	end
	
	def calc(move, player, ball, score, speed)
		for i in 0..1
			if move[i] == "up"
				player[i] += 10
			elsif move[i] == "down"
				player[i] -= 10
			end
			if player[i] <= 0
				player[i] = 0
			elsif player[i] >= 300
				player[i] = 300
			end
		end
		move_ball(ball, score, player, speed)
	end

	def move_ball(ball, score, player, speed)
		ball[0] += Math.cos(ball[2]) * ball[3]
		ball[1] += Math.sin(ball[2]) * ball[3]
		pi = Math::PI
		tpi = 2 * pi
		if ball[0] <= 20.0
			if ball[1].to_i - player[0] <= 100 && ball[1].to_i - player[0] >= 0
				ball[2] = (pi - ball[2] + tpi) % tpi
				ball[3] *= 1.01
				#add effect according to speed
			else
				score[1] += 1
				reset(player, ball, score, speed)
				return
			end
		elsif ball[0] >= 470.0
			if ball[1].to_i - player[1] <= 100 && ball[1].to_i - player[1] >= 0
				ball[2] = (pi - ball[2] + tpi) % tpi
				ball[3] *= 1.01
				#add effect according to speed
			else
				score[0] += 1
				reset(player, ball, score, speed)
				return
			end
		end
		if ball[1] <= 0.0
			ball[2] = (ball[2] * -1 + tpi) % tpi
		elsif ball[1] >= 390.0
			ball[2] = (tpi - ball[2]) % tpi
		end
	end

	def reset(player, ball, score, speed)
		ball[0] = 245.0
		ball[1] = 195.0
		ball[3] = speed
		player[0] = 75
		player[1] = 75
		score[2] = 30
	end
		

	def clean_list
		History.all.each do |game|
			if game.host == game.opponent && game.host == current_user
				game.destroy
			end
		end
	end
	
	def create
	end
	
	def delete
	end
end
