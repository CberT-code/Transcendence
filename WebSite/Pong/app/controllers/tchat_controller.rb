require 'securerandom'

class TchatController < ApplicationController
    before_action do |sign_n_out|
		if !user_signed_in?
			render 'pages/not_authentificate', :status => :unauthorized
		end
	end
	def index
		@channel = Channel.all.order("id");
	end
	def channelCreate
		if (!params[:title] || !params[:type])
			render html: "error-forbidden", :status => :unauthorized
		else
			@user_id = current_user.id
			@title = params[:title]
			@type = params[:type]
			@date = Date.today
			if (!Channel.find_by_title(@title))
				@key = SecureRandom.urlsafe_base64(8)
				Channel.create(:type_channel=> @type,:title=> @title, :user_id=> @user_id, :key=> @key, create_time=>@date)
				render html: "1"
			else
				render html: "2"
			end
		end
	end
end