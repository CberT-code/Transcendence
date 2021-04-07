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
		
		@history = @me.hosted_games.all #TO DO : merge and sort both
		@history_bis = @me.foreign_games.all
	end
	
	def show
		@me = current_user
		@game = History.find(params[:id])
	end

	def new
		redis = Redis.new(	url:  ENV['REDIS_URL'],
							port: ENV['REDIS_PORT'],
							db:   ENV['REDIS_DB'])
		@me = current_user
		game_found = "no"
		History.all.each do |target|
			if target.host != @me && target.statut == 0
				@game = target
				@game.opponent = @me
				redis.set("game_#{@game.id}", "ready")
				@game.save!
				game_found = "ok"
				redirect_to @game
				break
			end
		end
		if game_found != "ok"
			@game = @me.hosted_games.new(statut: -1, opponent: @me, host_height: 150, oppo_height: 150,
			ball_x: 245, ball_y: 195, ball_x_dir: 1, ball_y_dir: 1, host_score: 0, opponent_score: 0)
			@game.save!
			redis.set("game_#{@game.id}", "Looking For Opponent")
			redirect_to @game
		end
	end
	
	def wait
		redis = Redis.new(	url:  ENV['REDIS_URL'],
							port: ENV['REDIS_PORT'],
							db:   ENV['REDIS_DB'])
		frame = 0
		@game = History.find(params[:id])
		@game.save!
		status = redis.get("game_#{@game.id}")
		time = Time.now
		while status == "Looking For Opponent"
			sleep 0.25
			ActionCable.server.broadcast("pong_#{@game.id}", {body: "what is my purpose?", frame: frame, status: status})
			frame += 1
			status = redis.get("game_#{params[:id]}")
			if (Time.now.to_i - time.to_i > 30)
				break
			end
		end
		@game = History.find(params[:id])
		ActionCable.server.broadcast("pong_#{@game.id}", {body: "what is my purpose again?", frame: frame, status: status, right_pp: @game.opponent.image})
	end
	
	def run
		@game = History.find(params[:id])
		@game.statut = 2
		@game.save
		if current_user == @game.host
			redis = Redis.new(	url:  ENV['REDIS_URL'],
								port: ENV['REDIS_PORT'],
								db:   ENV['REDIS_DB'])
			status = "running"
			redis.set("game_#{@game.id}", status)
			frame = 0
			move = Array["static", "static"]
			player = Array[75, 75]
			score = Array[0, 0, 30]
			ball = Array[245.0, 195.0, 4.0, 7.0]
			
			while score[0] < 4 && score[1] < 4 && status == "running"
				move[1] = redis.get("player_#{@game.opponent.id}")
				move[0] = redis.get("player_#{@game.host.id}")
				time = Time.now
				if score[2] != 0
					score[2] -= 1
				else
					calc(move, player, ball, score)
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
				@game.save
			else
				@game.statut = -1
				@game.save
			end
			status = "ended"
			redis.set("game_#{@game.id}", status)
			ActionCable.server.broadcast("pong_#{@game.id}", {	body: "Left : #{move[0]} -- Right : #{move[1]}",
																frame: frame, status: status,
																left_y: player[0], right_y: player[1],
																ball_x: ball[0].to_i, ball_y: ball[1].to_i,
																score: "#{score[0]} - #{score[1]}"})
			redis.del("game_#{@game.id}")
		end
	end
	
	def calc(move, player, ball, score)
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
		move_ball(ball, score, player)
	end

	def move_ball(ball, score, player)
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
				reset(player, ball, score)
				return
			end
		elsif ball[0] >= 470.0
			if ball[1].to_i - player[1] <= 100 && ball[1].to_i - player[1] >= 0
				ball[2] = (pi - ball[2] + tpi) % tpi
				ball[3] *= 1.01
				#add effect according to speed
			else
				score[0] += 1
				reset(player, ball, score)
				return
			end
		end
		if ball[1] <= 0.0
			ball[2] = (ball[2] * -1 + tpi) % tpi
		elsif ball[1] >= 390.0
			ball[2] = (tpi - ball[2]) % tpi
		end
	end

	def reset(player, ball, score)
		ball[0] = 245.0
		ball[1] = 195.0
		ball[3] = 7.0
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
