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
			@type = params[:type].to_i
			@blocked_users = ""
			@date = Date.today
			if (!Channel.find_by_title(@title))
				@key = SecureRandom.urlsafe_base64(8)
				Channel.create(:type_channel=> @type,:title=> @title, :user_id=> @user_id, :key=> @key, :create_time=>@date, :blocked_users=>@blocked_users)
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
			if (@datas && (@datas.user_id == @user_id || @datas.type_channel == 2))
				render json: @datas
				return
			end
			render html: 2
			return 
		end
	end
	def getPrivateChannel
		if (!params[:id] || !params[:key])
			render html: "error-forbidden", :status => :unauthorized
		else
			@id = params[:id]
			@key = params[:key]
			@user_id = current_user.id
			@datas = Channel.find_by_id(@id)
			if (@datas && (@datas.key == @key || @datas.user_id == @user_id))
				render json: @datas
				return
			end
			render html: 2
			return 
		end
	end
	def getAdminBlockedUsers
		if (!params[:id])
			render html: "error-forbidden", :status => :unauthorized
			return
		end
		@id = params[:id]
		@user_id = current_user.id
		@datas = Channel.find_by_id_and_user_id(@id, @user_id)
		if (!@datas)
			render html: "error-forbidden", :status => :unauthorized
			return
		end
		@ret = Array.new
		if (@datas.blocked_users.kind_of?(Array))
			@tmp = @datas.blocked_users.split(",")
			@tmp.each do |element|
				@id = element.to_i
				@data = User.find_by_id(@id)
				if (@data)
					@ret.push({"user_id" => @id, "username" => @data.nickname});
				end
			end
		end
		render json: @ret
	end
	def sendMessageChannel
		if (!params[:id] || !params[:key] || !params[:message])
			render html: "error-fobidden", :status => :unauthorized
		else
			@id = params[:id]
			@key = params[:key]
			@message = params[:message]
			@user_id = current_user.id.to_s
			@datas = Channel.find_by_id(@id)
			@date = Date.today
			if (@datas && (@datas.user_id == @user_id || @datas.key == @key))
				if (@datas.blocked_users && @datas.blocked_users.split(",").include?(@user_id))
					render html: 2
					return
				end
				Messages.create(:user_id=> @user_id, :create_time=> @date, :message=> @message, :target_id=> @id, :message_type=> 1)
				render html: 1
				return
			end
			render html: "error-fobidden", :status => :unauthorized
			return
		end
	end
	def userBlockChannel
		@user_id = current_user.id.to_s
		if (!params[:id] || !params[:channelId] || !params[:type])
			render html: "error-fobidden", :status => :unauthorized
		elsif (params[:type] == "1")
			@block_user = params[:id]
			if (@user_id == @block_user)
				render html: "3"
				return
			end
			@channelId = params[:channelId]
			@datas = Channel.find_by_id_and_user_id(@channelId, @user_id)
			if (@datas)
				@tmp = @datas.blocked_users ? @datas.blocked_users.split(",") : Array.new
				if (!@tmp.include?(@block_user))
					@tmp.push(@block_user)
					@datas.update({blocked_users: @tmp.join(",")})
					@datas.save
					render html: "1"
					return 
				end
				render html: "2"
				return 
			end
		elsif (params[:type] == "2")
			@mute_user = params[:id]
			@channelId = params[:channelId]
			if (@user_id == @mute_user)
				render html: "3"
				return
			end
			@datas = Channel.find_by_id_and_user_id(@channelId, @user_id)
			if (@datas)
				@tmp = @datas.muted_users ? @datas.blocked_users.split(",") : Array.new
				if (!@tmp.include?(@block_user))
					@tmp.push(@block_user)
					@datas.update({muted_users: @tmp.join(",")})
					@datas.save
					render html: "1"
					return 
				end
				render html: "2"
				return 
			end
		elsif (params[:type] == "3")
			@mute_user = params[:id]
			@channelId = params[:channelId]
			if (@user_id == @mute_user)
				render html: "3"
				return
			end
			@datas = Channel.find_by_id_and_user_id(@channelId, @user_id)
			if (@datas)
				@tmp = @datas.muted_users ? @datas.blocked_users.split(",") : Array.new
				@tmp.delete(@mute_user)
				@datas.update({muted_users: @tmp.join(",")})
				render html: "1"
				return
			end
		end
		render html: "error-fobidden", :status => :unauthorized
	end
	def removeMessageChannel
		if (!params[:id] || !params[:channel_id])
			render html: "error-fobidden", :status => :unauthorized
		else
			@id = params[:id]
			@channel_id = params[:channel_id]
			@user_id = current_user.id
			if (Channel.find_by_user_id_and_id(@user_id, @channel_id))
				Messages.find_by_id(@id).destroy
				render html: "1"
				return 
			else
				render html: "error-fobidden", :status => :unauthorized
			end
		end
	end
	def removeBlockedUser
		if (!params[:key] || !params[:id])
			render html: "error-forbidden", :status => :unauthorized
			return
		end
		@key = params[:key]
		@id = params[:id]
		@user_id = current_user.id
		@datas = Channel.find_by_key(@key)
		if (@datas && @datas.user_id == @user_id)
			@tmp = @datas.blocked_users.split(",")
			@tmp.delete(@id)
			@datas.update({blocked_users: @tmp.join(",")})
			@datas.save
			render html: "1"
			return
		end
		render html: "error-forbidden", :status => :unauthorized
		return
	end
	def UpdateChannelKey
		if (!params[:id] || !params[:key])
			render html: "error-forbidden", :status => :unauthorized
		else
			@id = params[:id]
			@key = params[:key]
			@user_id = current_user.id
			@datas = Channel.find_by_id_and_user_id(@id, @user_id)
			if (@datas)
				if (@key !~ /[!@#$%^&*()_+{}\[\]:;'"\/\\?><.,]/)
					@datas.update({:key => @key})
					@datas.save
					render html: "1"
					return
				end
				render html: "2"
			end
		end
		render html: "error-forbidden", :status => :unauthorized
	end
	def UpdateChannelType
		if (!params[:channelId])
			render html: "error-forbidden", :status => :unauthorized
			return
		end
		@channelId = params[:channelId]
		@user_id = current_user.id
		@datas = Channel.find_by_id_and_user_id(@channelId, @user_id)
		if (@datas)
			@datas.update({type_channel: (@datas.type_channel == 1 ? 2 : 1)})
			@datas.save
			render html: "1"
			return
		end
		render html: "error-forbidden", :status => :unauthorized
		return
	end
	def getChannelMessage
		if (!params[:id] || !params[:key])
			render html: "error-fobidden", :status => :unauthorized
		else
			@id = params[:id]
			@key = params[:key]
			@user_id = current_user.id
			@channel = Channel.find_by_id_and_key(@id, @key)
			if (@channel)
				@datas = Messages.where(["target_id = ? AND message_type = ?", @id, '1'])
				@ret = Array.new
				@is_admin = @channel.user_id == @user_id ? 1 : 0
				@is_muted = (@channel.muted_users && @channel.muted_users.split(",").include?(@user_id.to_s)) ? 1 : 0
				@is_blocked = (@channel.blocked_users && @channel.blocked_users.split(",").include?(@user_id.to_s)) ? 1 : 0
 				@datas.each do |element|
					@tmp = User.find_by_id(element.user_id)
					@ret.push({"id" => element.id, "content" => element.message, "date" => element.create_time, "author" => @tmp.nickname, "author_id" => element.user_id, "admin" => @is_admin, "muted" => @is_muted, "blocked" => @is_blocked})
				end
				render json: @ret
			else
				render html: "error-fobidden", :status => :unauthorized
			end
		end
	end
end