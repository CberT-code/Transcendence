class MatchmakingController < ApplicationController
	skip_before_action :verify_authenticity_token
	
	before_action do |sign_n_out|
		if (start_conditions() == 1)
			if @me.locked
				render "/pages/otp"
			end
		end
	end

	def start
		tournament_id = params.fetch(:tournament_id, 1)
		ranked = params.fetch(:ranked, false)
		duel = params.fetch(:duel, false)
		opponent_id = params.fetch(:opponent_id, -1)
		war_match = params.fetch(:war_match, false)
		war_id = params.fetch(:war_id, -1)

		puts "\n\nDuel bool : #{duel}\n\n"

		if User.hasALiveGame(@me) != -1
			render json: {status: "error", info: "You already have an ongoing game"}
		elsif duel && opponent_id == -1
			render json: {status: "error", info: "invalid opponent_id"}
		elsif duel && User.isOnline(opponent_id) == "offline"
			render json: {status: "error", info: "Opponent is unavaible"}
		elsif duel && User.hasALiveGame(opponent_id) != -1
			render json: {status: "error", info: "Opponent already has an ongoing game"}
		elsif !duel && opponent_id != -1
			render json: {status: "error", info: "You cannot choose an opponent if the game is not a duel"}
		elsif Tournament.isAvailable(tournament_id) == false
			render json: {status: "error", info: "Unavailable tournament"}
		elsif Tournament.tUserExists(tournament_id, @me.id) == false
			render json: {status: "error", info: "You have not joined this tournament"}
		elsif opponent_id != -1 && Tournament.tUserExists(tournament_id, opponent_id) == false
			render json: {status: "error", info: "Opponent has not joined this tournament"}
		elsif duel && ranked
			render json: {status: "error", info: "Duels cannot be ranked"}
		elsif duel && war_match
			render json: {status: "error", info: "Invalid duel parameters"}
		elsif war_match && war_id == -1
			render json: {status: "error", info: "Invalid war_id"}
		elsif war_match && War.isAvailable(war_id) == false
			render json: {status: "error", info: "You cannot start a war match at the moment"}
		else
			tr = Tournament.find_by_id(tournament_id)
			oppo = User.find_by_id(opponent_id)
			if War.canDuel(@me, oppo)
				war_match = true
				war = @me.guild.war
			else
				war = War.find_by_id(war_id)
			end
			if join(war, tr, war_match, duel, ranked, oppo) == false
				create(war, tr, war_match, duel, ranked, oppo)
			end
		end
	end

	def join(war, tr, war_match, duel, ranked, oppo)
		if oppo != nil || duel != false
			return false
		end
		list = History.where("statut = ? AND war_id = ? AND tournament_id = ? AND ranked = ? AND war_match = ?", 0, war ? war.id : -1, tr.id, ranked, war_match)
		if !list
			return false
		end
		list.each do |game|
			puts game.id
			if !game.opponent && game.host != @me
				game.update(opponent: @me, statut: 2)
				@redis.set("game_#{game.id}", "Waiting for opponent")
				render json: {status: "ok", info: "Found a game", id: game.id}
				return true
			end
		end
		return false
	end

	def create(war, tr, war_match, duel, ranked, oppo)
		if duel
			timeout = 15
		elsif war
			timeout = war.timeout
		else
			timeout = -1
		end
		game = tr.games.new(host: @me, war_id: war ? war.id : -1, war_match: war_match,
			duel: duel, opponent: oppo, ranked: ranked, timeout: timeout, statut: duel ? 2 : 0)
		game.save!
		if war_match && !duel
			war.update(ongoingMatch: true)
			guilds = Guild.where(war_id: war.id)
			if guilds.first == @me.guild
				enemy_guild = guilds.last
			else
				enemy_guild = guilds.first
			end
			enemy_guild.notifyWarMatchRequest()
		elsif duel
			ActionCable.server.broadcast("presence_#{oppo.id}",
				{info: "#{@me.nickname} wants to duel you!",
				 id: game.id, type: "duel", color: "gold" })
		end
		@redis.set("game_#{game.id}", "Waiting for opponent")
		render json: {status: "ok", info: "Created a new game", id: game.id}
	end


	## DEPRECATED DO NOT USE ##

	# def duel
	# 	game = @me.findLiveGame()
	# 	if game != -1
	# 		render json: {status: "error",
	# 			info: "You already have a running game"}
	# 	elsif params.fetch(:opponent, -1) == -1
	# 			render json: {status: "error", info: "Invalid opponent_id"}
	# 	else

	# 		opponent = User.find_by_id(params['opponent'].to_i)
	# 		if opponent == @me
	# 			render json: {status: "error", info: "Got get a friend to duel"}
	# 			return
	# 		elsif opponent.isOnline() == "offline"
	# 			render json: {status: "error", info: "Opponent is offline"}
	# 			return
	# 		elsif opponent.findLiveGame() != -1
	# 			render json: {status: "error", info:
	# 				"Opponent already has a running game"}
	# 			return
	# 		end
	# 		tourn = Tournament.find_by_id(params['id'].to_i)
	# 		@me = current_user
	# 		if War.canDuel(@me, opponent)
	# 			war_id = @me.guild.war_id
	# 		else
	# 			war_id = -1
	# 		end
	# 		@game = tourn.games.new(statut: 0, host: @me, opponent: opponent,
	# 			host_score: 0, opponent_score: 0, ranked: false,
	# 			war_id: war_id, war_match: false, timeout: 30, duel: "pending")
	# 		@game.save!
	# 		redis.set("game_#{@game.id}", "Looking For Opponent")
	# 		ActionCable.server.broadcast("presence_#{opponent.id}",
	# 			{info: "#{@me.nickname} wants to duel you!",
	# 				id: @game.id, type: "duel", color: "gold" })
	# 		render json: {status: "Duel created!", id: @game.id}
	# 	end
	# end

	# def checkValidity(war_id)
	# 	war = War.find_by_id(war_id)
	# 	if war.ongoingMatch
	# 		return false
	# 	elsif war.start > Time.now || war.end < Time.now
	# 		return false
	# 	elsif war.wartime
	# 		return true
	# 	else
	# 		return false
	# 	end
	# end

	# def joinWarMatch
	# 	puts "\n\nJoining war march #{params[:game_id]}"
	# 	game = @me.findLiveGame()
	# 	puts game
	# 	if game != -1
	# 		render json: {status: "error", info: "You already have a running game"}
	# 	elsif !@me.guild || !@me.guild.war || @me.guild.war_id != params[:war_id]
	# 		render json: {status: "error", info: "You can't join this match"}
	# 	else
	# 		game = History.find_by_id(params[:game_id])
	# 		if !game
	# 			render json: {status: "error", info: "game does not exist"}
	# 		elsif game.host != game.opponent
	# 			render json: {stays: "ok", info: "One of your guild mates was faster"}
	# 		else
	# 			redis = Redis.new(url: ENV['REDIS_URL'], port: ENV['REDIS_PORT'], db: ENV['REDIS_DB'])
	# 			redis.set("game_#{game.id}", "ready")
	# 			game.update({opponent: @me})
	# 			render json: {status: "ok", info: "You accepted the challenge!"}
	# 		end
	# 	end
	# end

	# def find_or_create
	# 	game = @me.findLiveGame()
	# 	if game != -1
	# 		render json: {status: "error", info: "You already have a running game"}
	# 		return
	# 	end
	# 	tourn = Tournament.find_by_id(params['id'].to_i)
	# 	if (!tourn)
	# 		render json: {status: "error", info: "Invalid tournament ID"}
	# 		return
	# 	end
	# 	war_id = params.fetch(:war_id, -1)
	# 	timeout = params.fetch(:timeout, -1)
	# 	war_match = params.fetch(:war_match, "no") == "no" ? false : true

	# 	if war_match && war_id == -1
	# 		render json: {status: "error", info: "Invalid war ID"}
	# 		return
	# 	end
		
	# 	if war_match && !checkValidity(war_id)
	# 		render json: {status: "error", info: "Your guild cannot start a war match at the moment"}
	# 		return
	# 	end
		
	# 	redis = Redis.new(url: ENV['REDIS_URL'], port: ENV['REDIS_PORT'], db: ENV['REDIS_DB'])
	# 	tourn.games.each do |target|
	# 		if target.war_match == war_match && target.war_id == war_id &&
	# 				target.tournament_id == tourn.id && target.host != @me &&
	# 				target.opponent == target.host && target.statut == 0 &&
	# 				(target.timeout == -1 || Time.now - target.created_at < target.timeout)
	# 			target.statut = 2
	# 			target.opponent = @me
	# 			target.save!
	# 			if war_match
	# 				war = @me.guild.war
	# 				war.ongoingMatch = true
	# 				war.save!
	# 			end
	# 			@game = target
	# 			redis.set("game_#{@game.id}", "ready")
	# 			render json: {status: "Found a game!", id: @game.id}
	# 			return
	# 		end
	# 	end
	# 	@game = tourn.games.new(host: @me, opponent: @me, statut: 0,
	# 		ranked: params[:ranked] == "true" ? true : false,
	# 		war_id: war_id, war_match: war_match, timeout: timeout)
	# 	@game.save!
	# 	if war_match
	# 		if @me.guild.war.guild1 == @me.guild
	# 			@me.guild.war.guild2.notifyWarMatchRequest(@game.id)
	# 		else
	# 			@me.guild.war.guild1.notifyWarMatchRequest(@game.id)
	# 		end
	# 	end
	# 	redis.set("game_#{@game.id}", "Looking For Opponent")
	# 	render json: {status: "Game created!", id: @game.id}
	# end

	# def timeout
	# 	game = History.find_by_id(params[:id])
	# 	if game.timeout == -1
	# 		render json: {status: "ok", time_left: -1}
	# 	elsif Time.now - game.created_at < game.timeout
	# 		render json: {status: "ok", time_left: (game.timeout - (Time.now - game.created_at)).to_i}
	# 	elsif game.war_id == -1
	# 		game.statut = -1
	# 		game.save!
	# 		game.end_game_function
	# 		render json: {status: "forfeit", winner: game.host.nickname}
	# 	else
	# 		if game.war.guild1 == game.host.guild
	# 			opponent_guild = game.war.guild2
	# 		else
	# 			opponent_guild = game.war.guild1
	# 		end
	# 		game.opponent = opponent_guild.admin
	# 		game.opponent_score = -1
	# 		game.save!
	# 		game.end_game_function
	# 		render json: {status: "forfeit", winner: game.host.guild.name}
	# 	end
	# end

	## ##
end
