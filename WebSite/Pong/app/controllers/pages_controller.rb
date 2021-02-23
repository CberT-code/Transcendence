class PagesController < ApplicationController
	before_action do |sign_n_out|
		if !user_signed_in?
			render 'pages/not_authentificate', :status => :unauthorized
		end
	end
	
	def salut
		@name = params[:name]
	end

	def connexion
	end

	def home
		@session = session["devise.marvin_data"]
    @test_me = current_user.uid
	end
	def guilds_new
		if (User.find_by_id(current_user.id).id_guild != -1) then
			render 'pages/not_authentificate', :status => :unauthorized
		end
		
	def test
		@me = current_user
		# @me.status = 'LFO' # Looking For Opponent
		# raise
	end
end