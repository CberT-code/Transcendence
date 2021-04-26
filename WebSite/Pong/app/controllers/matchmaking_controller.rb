class MatchmakingController < ApplicationController
	skip_before_action :verify_authenticity_token
	
	before_action do |sign_n_out|
		if !user_signed_in?
			render 'pages/not_authentificate', :status => :unauthorized
		end
	end

	def duel
		redis = Redis.new(	url:  ENV['REDIS_URL'],
							port: ENV['REDIS_PORT'],
							db:   ENV['REDIS_DB'])
		tourn = Tournament.find(params['id'].to_i)
		opponent = User.find(params['opponent'].to_i)
		@me = current_user
		if @me.guild && @me.guild.war && opponent.guild && @me.guild.war == opponent.guild.war
			war_id = @me.guild.war_id
			war_match = true
		else
			war_id = -1
			war_match = false
		end
		@game = tourn.games.new(statut: 1, host: @me, opponent: opponent,
			host_score: 0, opponent_score: 0, ranked: false,
			war_id: war_id, war_match: war_match)
		@game.save!
		redis.set("game_#{@game.id}", "Looking For Opponent")
		render json: {status: "Duel created!", id: @game.id}
	end

	def checkValidity(war_id)
		war = War.find(war_id)
		if war.ongoingMatch
			return false
		elsif war.start > Time.now || war.end < Time.now
			return false
		elsif war.isWarTime()
			return true
		end
	end

	def find_or_create
		@me = current_user
		tourn = Tournament.find_by_id(params['id'].to_i)
		if (!tourn)
			render json: {status: "error", info: "Invalid tournament ID"}
			return
		end
		war_id = params.fetch(:war_id, -1)
		timeout = params.fetch(:timeout, -1)
		war_match = params.fetch(:war_match, "no") == "no" ? false : true
		
		if war_match && !checkValidity(war_id)
			render json: {status: "error", info: "Your guild cannot start a war match at the moment"}
			return
		end
		
		redis = Redis.new(url: ENV['REDIS_URL'], port: ENV['REDIS_PORT'], db: ENV['REDIS_DB'])
		tourn.games.each do |target|
			if target.war_match == war_match && target.war_id == war_id &&
					target.tournament_id == tourn.id && target.host != @me &&
					target.opponent == target.host && target.statut == 0 &&
					(target.timeout == -1 || Time.now - target.created_at < target.timeout)
				target.statut = 2
				target.opponent = @me
				target.save!
				if war_match
					@me.guild.war.ongoingMatch = true
					@me.guild.war.save!
				end
				@game = target
				redis.set("game_#{@game.id}", "ready")
				render json: {status: "Found a game!", id: @game.id}
				return
			end
		end
		@game = tourn.games.new(host: @me, opponent: @me,
			ranked: params[:ranked] == "true" ? true : false,
			war_id: war_id, war_match: war_match, timeout: timeout)
		@game.save!
		redis.set("game_#{@game.id}", "Looking For Opponent")
		render json: {status: "Game created!", id: @game.id}
	end

	def timeout
		game = History.find(params[:id])
		if game.timeout == -1
			render json: {status: "ok", time_left: -1}
		elsif Time.now - game.created_at < game.timeout
			render json: {status: "ok", time_left: (Time.now - game.created_at).to_i}
		else
			if game.war.guild1 == game.host.guild
				opponent_guild = game.war.guild2
			else
				opponent_guild = game.war.guild1
			end
			game.opponent = opponent_guild.admin
			game.opponent_score = -1
			game.save!
			game.end_game_function
			render json: {status: "forfeit"}
		end
	end
end
