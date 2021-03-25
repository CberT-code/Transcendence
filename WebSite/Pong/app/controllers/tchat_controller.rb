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
				Channel.create(:type_channel=> @type,:title=> @title, :user_id=> @user_id, :key=> @key, :create_time=>@date)
				render html: "1"
			else
				render html: "2"
			end
		end
	end
	def getChannel
		if (!params[:id])
			render html: "error-forbidden", :status => :unauthorized
		else
			@id = params[:id]
			@user_id = current_user.id
			@datas = Channel.find_by_id(@id)
			if (@datas && (@datas.user_id == @user_id || $datas.type_channel == 2))
				render json: @datas
			else
				render html: 2
			end
		end
	end
	def sendMessageChannel
		if (!params[:id] || !params[:key] || !params[:message])
			render html: "error-fobidden", :status => :unauthorized
		else
			@id = params[:id]
			@key = params[:key]
			@message = params[:message]
			@user_id = current_user.id
			@datas = Channel.find_by_id(@id)
			@date = Date.today
			if (@datas && (@datas.user_id == @user_id || @datas.key == @key))
				Messages.create(:user_id=> @user_id, :create_time=> @date, :message=> @message, :target_id=> @id, :message_type=> 1)
				render html: 1
			else
				render html: "error-fobidden", :status => :unauthorized
			end
		end
	end
	def getChannelMessage
		if (!params[:id] || !params[:key])
			render html: "error-fobidden", :status => :unauthorized
		else
			@id = params[:id]
			@key = params[:key]
			@user_id = current_user.id
			if (Channel.find_by_id_and_key(@id, @key))
				@datas = Messages.find_by_target_id_and_message_type(@id, 1);
				render json: @datas
			else
				render html: "error-fobidden", :status => :unauthorized
			end
		end
	end
end