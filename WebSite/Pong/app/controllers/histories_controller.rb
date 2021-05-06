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
		clean_list(-1)
		@me = current_user
		
		hosted = @me.hosted_games.all
		foreign = @me.foreign_games.all
		@games = (hosted + foreign).sort_by { |k| k.updated_at}.reverse!
		@spectate = History.where({statut: 2}).select("ranked", "tournament_id", "war_id", "host_id", "opponent_id", "id")
		@date = DateTime.new(1902,1,1,1,1,1);
		@tournament = Tournament.where(["(start < ?) OR ('end' > ? AND start < ?)", @date, DateTime.current, DateTime.current]);
	end

	def show
		id = params.fetch(:id, -1)
		clean_list(id)
		@game = History.find_by_id(id)
		if !@game || @game.statut == -1
			render "/pages/error-404"
			return
		end
	end

	def readyCheck
		game = History.find_by_id(params[:id])
		if (!game)
			render json: {status: "error", info: "Invalid game_id"}
		elsif @me == game.host
			render json: {status: "ok", info: "You are identified as left player"}
			if !game.host_ready
				game.update(host_ready: true)
				if game.opponent_ready
					@redis.set("game_#{@game.id}", "running")
					game.update(statut: 2)
					game.run()
				else
					game.wait()
				end
			end
		elsif @me == game.opponent
			render json: {status: "ok", info: "You are identified as right player"}
			if !game.opponent_ready
				game.update(opponent_ready: true)
				if @game.host_ready
					redis.set("game_#{@game.id}", "running")
					game.update(statut: 2)
					game.run()
				else
					game.wait()
				end
			end
		else
			render json: {status: "ok", info: "You are identified as spectator"}
		end
	end

	def forever_alone
		game = History.find_by_id(params[:id])
		if !game || game.opponent != nil || game.statut != 0
			render json: {status: "error", info: "You cannot do that now"}
		else
			game.update(statut: -1)
			@redis.set("game_#{game.id}", "ready")
			game.run()
			render json: {status: "ok", info: "Had fun alone?"}
		end
	end
	
	# def show_old_and_deprecated
	# 	id = params.fetch(:id, -1)
	# 	clean_list(params[:id].to_i)
	# 	@game = History.find_by_id(params[:id])
	# 	if @game == nil
	# 		render "/pages/error-404"
	# 		return
	# 	end
	# 	if @game.duel == "pending" && current_user == @game.opponent #duel stuff to prevent cheat with "forever alone" button
	# 		@game.update(duel: "accepted")
	# 	end
	# 	if (@game.statut == 3) #ended, show recap
	# 		@status = "ended"
	# 		@left = @game.host_score
	# 		@right = @game.opponent_score
	# 	elsif (@game.statut == -1) #error, should not be here
	# 		@status = "There was an error with this game"
	# 	else #live game!
	# 		if @me == @game.opponent && @me != @game.host # I'm the opponent
	# 			@status = "ready"
	# 			@game.update(statut: 2)
	# 			ActionCable.server.broadcast("pong_#{@game.id}",
	# 					{status: "ready", right_pp: @me.image})
	# 		elsif @me != @game.host && @me != @game.opponent && @game.host != @game.opponent # witnessing a live game
	# 			@status = "running"
	# 		else # game hasn't started yet
	# 			@status = "Looking For Opponent"
	# 		end
	# 	end
	# end

	def clean_list(id)
		History.all.each do |game|
			if (!game.opponent && game.host == current_user && game.id != id.to_i) ||
					game.statut == -1 
				ActionCable.server.broadcast("pong_#{game.id}", {status: "deleted"})
				puts "Deleting game #{game.id} status : #{game.statut} (#{id} excluded)"
				@redis.set("game_#{game.id}", "deleted")
				@redis.del("game_#{game.id}")
				game.destroy
			end
		end
	end
end
