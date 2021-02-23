class PagesController < ApplicationController
	before_action do |sign_n_out|
		if !user_signed_in?
			render 'pages/not_authentificate', :status => :unauthorized
		end
	end
	def home
		@session = session["devise.marvin_data"]
	end
	def guilds_new
		if (User.find_by_id(current_user.id).id_guild != -1) then
			render 'pages/not_authentificate', :status => :unauthorized
		end
	end
end