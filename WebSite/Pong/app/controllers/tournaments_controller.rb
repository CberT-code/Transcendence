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
		else
			@tournament = Tournament.new;
			@tournament.update({name: params[:tournamentname], description: params[:tournamentdescription], start: params[:start], end: params[:end]});
			@tournament.save;
			render html: @tournament.id;
		end
	end
	def show

	end
	def destroy
	
	end
	def join
		
	end

end