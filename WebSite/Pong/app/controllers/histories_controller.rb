class HistoriesController < ApplicationController
	before_action do |sign_n_out|
		if !user_signed_in?
			render 'pages/not_authentificate', :status => :unauthorized
		end
	end
	
	def index
		@me = current_user # to be removed ?

		@history = @me.hosted_games.all
		@history_bis = @me.foreign_games.all
	end

	def show
		@game = History.find(params[:id])
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
			@game = @me.hosted_games.new(statut: 0, opponent: @me)
		@game.save!
		redirect_to @game
		end
	end

	def create
	end

	def delete
	end
end
