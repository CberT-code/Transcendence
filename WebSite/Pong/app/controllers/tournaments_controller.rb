class TournamentsController < ApplicationController
	before_action do |sign_n_out|
		if (start_conditions() == 1)
			if @me.locked
				render "/pages/otp"
			end
		end
	end

	def index
		@tournaments = Tournament.all.order('name').order(:id).reverse_order
	end
	def new
		if (@me.role != 1)
			render html: "error-forbidden", :status => :unauthorized
		else
			@tournament = Tournament.new
		end
	end
	def playerJoin
		if (TournamentUser.where(["user_id = ? and tournament_id = ?", current_user.id, params[:id_tournament]]).count == 0)
			if ( is_number?(params[:id_tournament]))
				TournamentUser.create({tournament_id: params[:id_tournament], user_id: current_user.id })
			end
		else
			render html: "error-joined";
		end
	end
	def create
		if (@me.role == 1)
			if (params[:tournamentname] == "" || !safestr(params[:tournamentname]))
				render html: "error-1";
			elsif (params[:tournamentdescription] == "" || !safesentence(params[:tournamentdescription]))
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
		else
			render html: "error-forbidden"
		end
	end
	
	def show
		@tournament = Tournament.find_by_id(params[:id])
		if (@tournament == nil)
			render "/pages/error-404"
			return
		end
		@t_users = @tournament.t_users.all.sort_by { |u| [u.elo]}.reverse
		@wars_histories = History.where(['tournament_id = ? AND ranked = ?', @tournament.id, true]).order(:id).reverse_order
	end

end