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
		elsif war_match && War.isWarrior(@me)
			render json: {status: "error", info: "You are not part of a war team"}
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
			if !game.opponent && game.host != @me
				if game.war
					if game.war.ongoingMatch1 && @me.guild != game.host.guild
						game.war.update(ongoingMatch2: true)
					else
						return false
					end
				end
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
			if war.ongoingMatch1
				render json: {status: "error", info: "You cannot start a war match at the moment (send from matchmaking#create)"}
				return 
			end
			timeout = 20
		else
			timeout = -1
		end
		game = tr.games.new(host: @me, war_id: war ? war.id : -1, war_match: war_match,
			duel: duel, opponent: oppo, ranked: ranked, timeout: timeout, statut: duel ? 2 : 0)
		game.save!
		if war_match && !duel
			war.update(ongoingMatch1: true)
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
end
