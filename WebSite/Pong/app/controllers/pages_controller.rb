class PagesController < ApplicationController
	before_action do |sign_n_out|
		if !user_signed_in?
			render 'pages/not_authentificate', :status => :unauthorized
		end
	end
	# def home
	# 	@session = session["devise.marvin_data"]	
	# end
end