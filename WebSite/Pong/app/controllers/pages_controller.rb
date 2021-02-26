class PagesController < ApplicationController
	before_action do |sign_n_out|
		if !user_signed_in?
			render 'pages/not_authentificate', :status => :unauthorized
		end
	end
	def home
		@session = session["devise.marvin_data"]	
	end
	def account
		@histories = History.where('(target_1 = ? or target_2 = ?) and target_type = ?', current_user.id, current_user.id, 1);
	end
end