class PostController < ApplicationController
	before_action do |sign_n_out|
		if !user_signed_in?
			render 'pages/not_authentificate', :status => :unauthorized
		end
	end
	def deleteAccount
		Stat.find_by_id(current_user.id_stats).destroy
		User.find_by_id(current_user.id).destroy
		destroy_user_session_path
		render html: "1"
	end
end