class HistoriesController < ApplicationController
	skip_before_action :verify_authenticity_token
	
	before_action do |sign_n_out|
		if (start_conditions() == 1)
			if @me.locked
				render "/pages/otp"
			end
		end
	end
	
	def index
		History.clean_list(-1, current_user)
		@me = current_user
		
		hosted = @me.hosted_games.all
		foreign = @me.foreign_games.all
		@games = (hosted + foreign).sort_by { |k| k.updated_at}.reverse!
		@spectate = History.where({statut: 2}).select("ranked", "tournament_id", "war_id", "host_id", "opponent_id", "id")
		@date = DateTime.new(1902,1,1,1,1,1);
		@tournament = Tournament.where({status: 1});
	end

	def show
		id = params.fetch(:id, -1)
		History.clean_list(id, current_user)
		@game = History.find_by_id(id)
		if !@game || @game.statut == -1
			render "/pages/error-404"
			return
		elsif @game.statut == 3
			ActionCable.server.broadcast("pong_#{@game.id}",
				{status: "ended",
				winner: @game.host_score > @game.opponent_score ? @game.host_id : @game.opponent_id,
				loser: @game.host_score < @game.opponent_score ? @game.host_id : @game.opponent_id,
				w_name: @game.host_score > @game.opponent_score ? @game.host.nickname : @game.opponent.nickname})
		end
	end

	def readyCheck
		game = History.find_by_id(params[:id])
		ret = ""
		if (!game)
			render json: {status: "error", info: "Invalid game_id"}
			return
		elsif @me == game.host
			if !game.host_ready
				game.update(host_ready: true)
				if game.opponent_ready
					@redis.set("game_#{game.id}", "running")
					game.update(statut: 2)
					ret =game.run()
				else
					ret = game.wait()
				end
			end
		elsif @me == game.opponent
			if !game.opponent_ready
				game.update(opponent_ready: true)
				if game.host_ready
					@redis.set("game_#{game.id}", "running")
					game.update(statut: 2)
					ret = game.run()
				else
					ret = game.wait()
				end
			end
		else
			render json: {status: "ok", info: "You are identified as spectator"}
			return
		end
		if ret == "timeout"
			render json: {status: ret, info: "Game timed out!"}
		elsif ret == "disconnect"
			render json: {status: ret, info: "Both players left, game cancelled"}
		else
			render json: {status: "ok", info: ret}
		end
	end
end
