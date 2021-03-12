class HistoriesController < ApplicationController
	skip_before_action :verify_authenticity_token
	before_action do |sign_n_out|
		if !user_signed_in?
			render 'pages/not_authentificate', :status => :unauthorized
		end
	end
	
	def index
		clean_list
		@me = current_user # to be removed ?

		@history = @me.hosted_games.all
		@history_bis = @me.foreign_games.all
	end

	def show
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
			@game = @me.hosted_games.new(statut: 0, opponent: @me, host_height: 150, oppo_height: 150)
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

		render :json => {'status': @game.statut, 'right_pp': @game.opponent.image, 'host': @game.host_height, 'oppo': @game.oppo_height }
	end

	def run
		@game = History.find(params[:id])
		@me = current_user

		if @me == @game.host

			# BALL MOVE
			@game.ball_x += 5 * @game.ball_x_dir 
			@game.ball_y += 5 * @game.ball_y_dir
			if @game.ball_x <= 20 || @game.ball_x >= 470
				@game.ball_x_dir *= -1
			end
			if @game.ball_y <= 0 || @game.ball_y >= 390
				@game.ball_y_dir *= -1
			end
			# END OF BALL MOVE

		# HOST MOVE
			if (params['up'].to_i != 0)
				@game.host_height -= 10
				if @game.host_height < 0
					@game.host_height = 0
				end
			end
			if (params['down'].to_i != 0)
				@game.host_height += 10
				if @game.host_height > 300
					@game.host_height = 300
				end
			end
			@game.save!
		
		# OPPONENT MOVE
		elsif @me == @game.opponent
			if (params['up'].to_i != 0)
				@game.oppo_height -= 10
				if @game.oppo_height < 0
					@game.oppo_height = 0
				end
			end
			if (params['down'].to_i != 0)
				@game.oppo_height += 10
				if @game.oppo_height > 300
					@game.oppo_height = 300
				end
			end
			@game.save!
		end

		render :json => {'id': @game.id, 'status': @game.statut, 'left': @game.host_height, 'right': @game.oppo_height, 'ball_x': @game.ball_x, 'ball_y': @game.ball_y }

	end
end
