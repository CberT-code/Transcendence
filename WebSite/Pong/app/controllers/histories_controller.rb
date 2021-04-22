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
		@spectate = History.where(statut: 2)
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
		if (@game.statut == 3) #ended, show recap
			@status = "ended"
			@left = @game.host_score
			@right = @game.opponent_score
		elsif (@game.statut == -1) #error, should not be here
			@status = "There was an error with this game"
		else #live game!
			@status = "Looking For Opponent"
			if @me == @game.opponent && @me != @game.host
				@status = "ready"
				ActionCable.server.broadcast("pong_#{@game.id}",
						{status: "ready", right_pp: @game.opponent.image})
			end
		end
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
end
