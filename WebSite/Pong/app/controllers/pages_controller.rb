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
	end
end