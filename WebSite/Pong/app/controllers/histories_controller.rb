class HistoriesController < ApplicationController
	before_action do |sign_n_out|
		if !user_signed_in?
			render 'pages/not_authentificate', :status => :unauthorized
		end
	end
	
	def index
		@me = current_user
	end

	def show
	end

	def new
	end

	def create
	end

	def delete
	end
end
