class TournamentsController < ApplicationController
	before_action do |sign_n_out|
		start_conditions()
		if @me.locked
			render "/pages/otp"
		end
	end

	def index
		@tournaments = Tournament.all.order('name').order(:id).reverse_order
	end
	def new
		@tournament = Tournament.new
	end
	def playerJoin
		if (TournamentUser.where("user_id = ? and tournament_id = ?", current_user.id, params[:id_tournament]).count == 0) 
			TournamentUser.create({tournament_id: params[:id_tournament], user_id: current_user.id })
		end
	end
	def create
		if (params[:tournamentname] == "")
			render html: "error-1";
		elsif (params[:tournamentdescription] == "")
			render html: "error-2";
		elsif (params[:start] == "")
			render html: "error-3";
		elsif (params[:end] == "")
			render html: "error-4";
		elsif (params[:maxpoints].to_i < 1 || params[:maxpoints].to_i > 15)
			render html: "error-5";
		elsif (params[:speed].to_i < 1 || params[:speed].to_i > 11)
			render html: "error-6";
		else
			@tournament = Tournament.new;
			@status = 0;

			if ((params[:start].to_date - DateTime.current.to_date).to_i == 0)
				@status = 1;
			end
			@tournament.update({name: params[:tournamentname], description: params[:tournamentdescription], start: params[:start], end: params[:end], maxpoints: params[:maxpoints], speed: params[:speed], status: @status});
			@tournament.save;
			render html: @tournament.id;
		end
	end
	def show
		@tournament = Tournament.find_by_id(params[:id]);
		@tournament_histories = TournamentUser.where('tournament_id = ?', @tournament.id).order(:difference).reverse_order;
		@wars_histories = History.where('tournament_id = ?', @tournament.id).order(:id).reverse_order;
	end

	def destroy
	end

	def join
	end

end