class TournamentsController < ApplicationController
	before_action do |sign_n_out|
		if !user_signed_in?
			render 'pages/not_authentificate', :status => :unauthorized
		end
	end

	def index
		@tournaments = Tournament.all.order('name')
	end
	def new
		@tournament = Tournament.new
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
			@tournament.update({name: params[:tournamentname], description: params[:tournamentdescription], start: params[:start], end: params[:end], maxpoints: params[:maxpoints], speed: params[:speed]});
			@tournament.save;
			render html: @tournament.id;
		end
	end
	def show
		@tournament = Tournament.find_by_id(params[:id]);
		@wars_histories = History.where('tournament_id = ?', @tournament.id);
	end

	def destroy
	end

	def join
	end

end