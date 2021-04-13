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
			@type = CGI.escapeHTML(params[:type]).to_i
			@date = Date.today
			if (!safestr(@title))
				render html: "3"
				return
			end
			if (!Channel.find_by_title(@title) && (@type == 1 || @type == 2))
				@key = SecureRandom.urlsafe_base64(8)
				Channel.create(:type_channel=> @type,:title=> @title.html_safe, :user_id=> @user_id, :key=> @key, :create_time=>@date)
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
			@id = CGI.escapeHTML(params[:id])
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
			@id = CGI.escapeHTML(params[:id])
			@key = CGI.escapeHTML(params[:key])
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
		render html: "1"
		return
	end
	def sendMessageChannel
		if (!params[:id] || !params[:key] || !params[:message])
			render html: "error-fobidden", :status => :unauthorized
		else
			@id = CGI.escapeHTML(params[:id])
			@key = CGI.escapeHTML(params[:key])
			@message = CGI.escapeHTML(params[:message])
			@user_id = current_user.id.to_s
			@datas = Channel.find_by_id(@id)
			@sanction = Sanctions.find_by_user_id_and_target_id(@datas.id, @user_id)
			@date = Date.today
			if (@datas && (@datas.user_id == @user_id || @datas.key == @key))
				if (@sanctions && @sanction.end_time <= Time.new.to_i && @sanction.sanction_type == 1)
					render html: 2
					return
				end
				Messages.create(:user_id=> @user_id, :create_time=> @date, :message=> @message.html_safe, :target_id=> @id, :message_type=> 1)
				render html: 1
				return
			end
			render html: "error-fobidden", :status => :unauthorized
			return
		end
	end
	def userBlockChannel
		@user_id = current_user.id
		if (!params[:id] || !params[:channelId] || !params[:type])
			render html: "error-fobidden", :status => :unauthorized
		elsif (params[:type] == "1" || params[:type] == "2")
			@block_user = CGI.escapeHTML(params[:id]).to_i
			if (@user_id == @block_user)
				render html: "3"
				return
			end
			@channelId = CGI.escapeHTML(params[:channelId])
			@datas = Channel.find_by_id_and_user_id(@channelId, @user_id)
			if (@datas)
				Sanctions.create(:sanction_type=> @type.to_i, :user_id=> @datas.id, target_id: @block_user, :create_time=>@date)
				render html: "1"
				return 
			end
		elsif (params[:type] == "3")
			@mute_user = CGI.escapeHTML(params[:id])
			@channelId = CGI.escapeHTML(params[:channelId])
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
	def removeChannel
		if (!params[:channel_id] || !safestr(params[:channel_id]))
			render html: "error-forbidden", :status => :unauthorized
			return
		end
		@channel_id = params[:channel_id]
		@user_id = current_user.id
		@datas = Channel.find_by_id(@channel_id)
		if (@datas && @datas.user_id == @user_id)
			@tmp = Messages.where(["target_id = ?", @channel_id])
 			@tmp.each do |element|
				element.destroy
			end
			@datas.destroy
			render html: "1"
			return
		end
	end
	def removeMessageChannel
		if (!params[:id] || !params[:channel_id])
			render html: "error-fobidden", :status => :unauthorized
			return
		else
			@id = CGI.escapeHTML(params[:id])
			@channel_id = CGI.escapeHTML(params[:channel_id])
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
	def ApplySanction
		if (!params[:channel_id] || !params[:target_id] || !params[:type])
			render html: "error-fobidden", :status => :unauthorized
			return
		end
		@channel_id = CGI.escapeHTML(params[:channel_id])
		@target_id = CGI.escapeHTML(params[:target_id])
		@type = CGI.escapeHTML(params[:type]).to_i
		@datas = Channel.find_by_id(@channel_id)
		if (@datas && @datas.user_id == current_user.id)
			if (@target_id.to_i == current_user.id)
				render html: "2"
				return
			end
			if (@type == 1)
				Sanctions.create(:sanction_type=> 1, :user_id=> @channel_id, :target_id=> @target_id, :create_time=>@date, :end_time => (Time.now.to_i + 99999))
				render html: "1"
				return 
			elsif (@type == 2)
				@tmp = Sanctions.find_by_target_id_and_user_id(@target_id, @channel_id)
				if (@tmp.sanction_type == 1)
					@tmp.destroy
				end
				render html: "1"
				return 
			elsif (@type == 3)
				Sanctions.create(:sanction_type=> 1, :user_id=> @channel_id, :target_id=> @target_id, :create_time=>@date, :end_time => (Time.now.to_i + 99999))
				render html: "1"
				return 
			elsif (@type == 4)
				@tmp = Sanctions.find_by_target_id_and_user_id(@target_id, @channel_id)
				if (@tmp.sanction_type == 2)
					@tmp.destroy
				end
				render html: "1"
				return 
			end
		end
	end
	def UpdateChannelKey
		if (!params[:id] || !params[:key])
			render html: "error-forbidden", :status => :unauthorized
			return
		else
			@id = CGI.escapeHTML(params[:id])
			@key = CGI.escapeHTML(params[:key])
			@user_id = current_user.id
			@datas = Channel.find_by_id_and_user_id(@id, @user_id)
			if (@datas)
				if (safestr(@key))
					@datas.update({:key => @key})
					@datas.save
					render html: "1"
					return
				end
				render html: "2"
				return
			end
		end
		render html: "error-forbidden", :status => :unauthorized
		return
	end
	def UpdateChannelType
		if (!params[:channelId])
			render html: "error-forbidden", :status => :unauthorized
			return
		end
		@channelId = CGI.escapeHTML(params[:channelId])
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
	def isChannelAdmin
		if (!params[:id])
			render html: "error-forbidden", :status => :unauthorized
			return
		end
		@id = params[:id]
		@user_id = current_user.id
		@datas = Channel.find_by_id(@id)
		if (@datas)
			if (@datas.user_id == @user_id)
				render html: "1"
				return
			end
			render html: "2"
			return
		end
		render html: "error-forbidden", :status => :unauthorized
		return
	end
	def exchangeChannelAdmin
		if (!params[:newAdmin] || !params[:channel_id])
			render html: "error-forbidden", :status => :unauthorized
			return
		end
		@newAdmin = params[:newAdmin]
		@user_id = current_user.id
		@channel_id = params[:channel_id]
		@datas = Channel.find_by_id_and_user_id(@channel_id, @user_id)
		@user_info = User.find_by_name(@newAdmin)
		if (@datas)
			if (@user_info)
				@datas.update({user_id: @user_info.id})
				@datas.save
				render html: "1"
				return
			end
			render html: "2"
			return
		end
		render html: "error-forbidden", :status => :unauthorized
	end
	def getChannelMessage
		if (!params[:id] || !params[:key])
			render html: "error-fobidden", :status => :unauthorized
			return
		else
			@id = params[:id]
			@key = params[:key]
			@user_id = current_user.id
			@channel = Channel.find_by_id_and_key(@id, @key)
			if (@channel)
				@datas = Messages.where(["target_id = ? AND message_type = ?", @id, '1'])
				@ret = Array.new
				@is_admin = @channel.user_id == @user_id ? 1 : 0
 				@datas.each do |element|
					@tmp = User.find_by_id(element.user_id)
					@sanction = Sanctions.find_by_user_id_and_target_id(@channel.id, element.user_id)
					@is_ban = (@sanction && @sanction.end_time > Time.new.to_i && @sanction.sanction_type == 1) ? 1 : 0
					@is_mute = (@sanction && @sanction.end_time > Time.new.to_i && @sanction.sanction_type == 2) ? 1 : 0
					@ret.push({"id" => element.id, "content" => element.message, "date" => element.create_time, "author" => @tmp.nickname, "author_id" => element.user_id, "admin" => @is_admin, "muted" => @is_mute, "ban" => @is_ban})
				end
				render json: @ret
				return
			end
			render html: "error-fobidden", :status => :unauthorized
			return
		end
	end
	def getSanctions
		if (!params[:type] || !params[:id] || !safestr(params[:id]) || !safestr(params[:type]))
			render html: "error-forbidden", :status => :unauthorized
			return
		end
		@type = params[:type]
		@channel_id = params[:id]
		@datas = Sanctions.find_by_user_id_and_sanction_type(@channel_id, @type)
		if (@datas)
			@ret = Array.new
			@datas.each do |element|
				@tmp = User.find_by_id(element.target_id)
				@ret.push({"id" => element.id, "target_name" => element.nickname, "sanction_type" => @element.sanction_type})
			end
			render json: @ret
			return
		end
	end
	def addSanction
		if (!params[:id] || !params[:nickname] || !params[:time] || !params[:type] || !safestr(params[:id]) || !safestr(params[:nickname]) || !safestr(params[:time]) || !safestr(params[:type]))
			render html: "errorr-forbidden", :status => :unauthorized
			return
		end
		@channel_id = params[:id]
		@nickname = params[:nickname]
		@type = params[:type]
		@time = params[:time].to_i
		@datas = Channel.find_by_id(@channel_id)
		@user_datas = User.find_by_nickname(@nickname)
		if (@datas && @datas.user_id == current_user.id)
			if (!@user_datas)
				render html: "2"
				return
			end
			Sanctions.create(:sanction_type=> @type,:user_id=> @channel_id, :target_id=> @user_datas.id, :end_time=> (Time.now.to_i + @time), :create_time=> Date.today)
			render html: "1"
			return
		end
		render html: "errror-forbidden", :status => :unauthorized
		return
	end
end