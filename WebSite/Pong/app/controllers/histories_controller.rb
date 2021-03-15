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

	def clean_list
		History.all.each do |game|
			if game.host == game.opponent && game.host == current_user
				game.destroy
			end
		end
	end

	def new
		@me = current_user
		game_found = "no"
		History.all.each do |target|
			if target.host != @me && target.statut == 0
				@game = target
				@game.opponent = @me
				@game.statut = 1
				@game.save!
				game_found = "ok"
				redirect_to @game
				break
			end
		end
		if game_found != "ok"
			@game = @me.hosted_games.new(statut: 0, opponent: @me, host_height: 150, oppo_height: 150,
				ball_x: 245, ball_y: 195, ball_x_dir: 1, ball_y_dir: 1, host_score: 0, opponent_score: 0)
		@game.save!
		redirect_to @game
		end
	end

	def create
	end

	def delete
	end

	def wait
		@game = History.find(params[:id])
		test = 0
		fps = 1.0
		
		render :json => {'status': @game.statut, 'right_pp': @game.opponent.image, 'host': @game.host_height, 'oppo': @game.oppo_height }
		
		while @game.statut != 3
			time = Time.now
			ActionCable.server.broadcast("pong_#{@game.id}", { body: "This is Sparta (#{@game.id})", test_var: test, fps: 1.0/fps})
			test += 1
			while Time.now.to_f <= time.to_f + 0.033
				sleep 1.0/300.0
			end
			fps = Time.now.to_f - time.to_f
		end
		# if params[:ready] == "ok" && current_user == @game.host
		# 	@game.statut = 2
		# end

		# @game.save!

	end

	def move_ball(game)
		@game.ball_x += 5 * @game.ball_x_dir 
		@game.ball_y += 5 * @game.ball_y_dir
		if @game.ball_x <= 20 || @game.ball_x >= 470
			@game.ball_x_dir *= -1
		end
		if @game.ball_y <= 0 || @game.ball_y >= 390
			@game.ball_y_dir *= -1
		end
	end

	def move_host(game, up, down)
		test = rand(30)
		if test  == 0
			game.host_score += 1
		elsif test == 1
			game.opponent_score += 1
		end
		if (up != 0)
			game.host_height -= 10
			if game.host_height < 0
				game.host_height = 0
			end
		end
		if (down != 0)
			game.host_height += 10
			if game.host_height > 300
				game.host_height = 300
			end
		end
	end

	def move_opponent(game, up, down)
		if (up != 0)
			game.opponent_height -= 10
			if game.opponent_height < 0
				game.opponent_height = 0
			end
		end
		if (down != 0)
			game.opponent_height += 10
			if game.opponent_height > 300
				game.opponent_height = 300
			end
		end
	end

	def check_bounce(game)
	end

	def check_score(game)
		if game.opponent_score >= 5 || game.host_score >= 5
			game.statut = 3
		end
	end

	def run
		@game = History.find(params[:id])
		@me = current_user

		if @me == @game.host
			move_ball(@game)
			move_host(@game, params['up'].to_i, params['down'].to_i)
		elsif @me == @game.opponent
			move_opponent(@game, params['up'].to_i, params['down'].to_i)
		end
		check_bounce(@game)
		check_score(@game)
		@game.save!

		ActionCable.server.broadcast("pong_21", { body: "This is Sparta (21) "})

		render :json => {'id': @game.id, 'status': @game.statut, 'left': @game.host_height, 'right': @game.oppo_height,
			'ball_x': @game.ball_x, 'ball_y': @game.ball_y, 'host': @game.host_score, 'oppo': @game.opponent_score }

	end

	def tmp
	end
end