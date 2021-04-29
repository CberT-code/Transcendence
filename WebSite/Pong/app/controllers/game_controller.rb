class GameController < ApplicationController
	skip_before_action :verify_authenticity_token
	
	before_action do |sign_n_out|
		if !user_signed_in?
			render 'pages/not_authentificate', :status => :unauthorized
		elsif @me.locked
			render "/pages/otp"
		end
	end
	
	def run
		game = History.find(params[:id])
		if current_user == game.host # UNCOMMENT THIS LINE OR FACE A SHITSTORM
			redis = Redis.new(	url:  ENV['REDIS_URL'],
								port: ENV['REDIS_PORT'],
								db:   ENV['REDIS_DB'])
			status = "running"
			redis.set("game_#{game.id}", status)
			frame = 0
			move = Array["static", "static"]
			player = Array[37, 37]
			score = Array[0, 0, 30] # score[2] serves as a countdown
			ball = Array[49, 49, 0.0, game.tournament.speed] # [x, y, angle, speed]
			
			while score[0] < game.tournament.maxpoints && score[1] < game.tournament.maxpoints && status == "running"
				move[1] = redis.get("player_#{game.opponent.id}")
				move[0] = redis.get("player_#{game.host.id}")
				time = Time.now
				if score[2] != 0
					score[2] -= 1
				else
					calc(move, player, ball, score, game.tournament.speed)
				end
				ActionCable.server.broadcast("pong_#{game.id}", {	frame: frame, status: status,
																	left_y: "#{player[0]}%", right_y: "#{player[1]}%",
																	ball_x: "#{ball[0]}%", ball_y: "#{ball[1]}%",
																	score: "#{score[0]} - #{score[1]}"})
				while Time.now.to_f <= time.to_f +	0.0417
					sleep 1.0/500.0
				end
				status = redis.get("game_#{game.id}")
				frame += 1
			end
			if (status == "running" && game.host != game.opponent)
				game.statut = 3
			else
				game.statut = -1
			end
			game.host_score = score[0]
			game.opponent_score = score[1]
			game.save!
			redis.set("player_#{game.host_id}", "online")
			redis.set("player_#{game.opponent_id}", "online")
			redis.del("game_#{game.id}")
			if game.statut == 3
				game.end_game_function()
			else
				ActionCable.server.broadcast("pong_#{game.id}", {status: "ended", right_pp: "https://pbs.twimg.com/profile_images/2836953017/11dca622408bf418ba5f88ccff49fce1.jpeg", elo: "0.42", winner: @me.id, loser: @me.id, w_name: "alone_dude"})
			end
			render html: "score: #{score[0]} - #{score[1]} - #{"ended"} - #{game.statut}"
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
end
