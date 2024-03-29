require 'securerandom'

class TchatController < ApplicationController
    before_action do |sign_n_out|
		if (start_conditions() == 1)
			if @me.locked
				render "/pages/otp"
			end
			History.clean_list(-1, current_user)
		end
	end

	def index
		@channels = Channel.all.order("id")
		@channel = Array.new
		@channels.each do |element|
			if (hasSanction(element.id, current_user.id, 1) == false)
				@channel.push({"id" => element.id, "title" => element.title, "type_channel" => element.type_channel, "user_id" => element.user_id})
			end
		end
		@tmp = Messages.where({user_id: current_user.id, message_type: 2}).all.or(Messages.where({target_id: current_user.id, message_type: 2}).all)
		@sanctions =  Sanctions.where({user_id: current_user.id, sanction_type: 3})
		@messages = Array.new
		@tmp.each do |element|
			@datas = element.user_id == current_user.id ? User.find_by_id(element.target_id) : User.find_by_id(element.user_id)
			@blocked = Sanctions.where({user_id: current_user.id, target_id: @datas.id, sanction_type: 3}).count == 0 ? 1 : 2
			if (!findInArrayObj(@messages, @datas.nickname))
				if (@blocked == 1)
					@messages.push({"image" => @datas.image, "nickname" => @datas.nickname, "target_id" => @datas.id, "blocked" => 1})
				end
			end
		end
		@sanctions.each do |element|
			@datas = User.find_by_id(element.target_id)
			if (!findInArrayObj(@messages, @datas.nickname))
				@messages.push({"image" => @datas.image, "nickname" => @datas.nickname, "target_id" => @datas.id, "blocked" => 2})
			end
		end
		render "tchat/index"
		return
	end
	def channelCreate
		if (!params[:title] || !params[:type])
			render html: "error-forbidden", :status => :unauthorized
		else
			@user_id = current_user.id
			@title = CGI.escapeHTML(params[:title])
			@type = CGI.escapeHTML(params[:type]).to_i
			@date = Date.today
			if (@title.length == 0 || @title.length > 45)
				render html: "error-forbidden", :status => :unauthorized
				return
			end
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
			@id = CGI.escapeHTML(params[:id]).to_i
			@user_id = current_user.id
			@datas = Channel.find_by_id(@id)
			if (@datas && (@datas.user_id == @user_id || current_user.role == 1 || @datas.type_channel == 2))
				if (hasSanction(@datas.id, current_user.id, 1) == false)
					render json: @datas
					return
				end
			end
			render html: 2
			return 
		end
	end
	def getPrivateChannel
		if (!params[:id] || !params[:key])
			render html: "error-forbidden", :status => :unauthorized
		else
			@id = CGI.escapeHTML(params[:id]).to_i
			@key = CGI.escapeHTML(params[:key])
			@user_id = current_user.id
			@datas = Channel.find_by_id(@id)
			if (@datas && (@datas.key == @key || @datas.user_id == @user_id || current_user.role == 1))
				if (hasSanction(@datas.id, current_user.id, 1) == false)
					render json: @datas
					return
				end
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
			@id = CGI.escapeHTML(params[:id]).to_i
			@key = CGI.escapeHTML(params[:key])
			@message = CGI.escapeHTML(params[:message])
			if (@message.length == 0 || @message.length > 90)
				render html: "error-forbidden", :status => :unauthorized
				return
			end
			@user_id = current_user.id
			@datas = Channel.find_by_id(@id)
			@sanction = Sanctions.find_by_user_id_and_target_id(@datas.id, @user_id)
			@date = Date.today
			if (@datas && (@datas.user_id == @user_id || @datas.key == @key))
				if (hasSanction(@datas.id, current_user.id, 1) == true || hasSanction(@datas.id, current_user.id, 2) == true)
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
	def removeChannel
		if (!params[:channel_id] || !safestr(params[:channel_id]))
			render html: "error-forbidden", :status => :unauthorized
			return
		end
		@channel_id = CGI.escapeHTML(params[:channel_id]).to_i
		@user_id = current_user.id
		@datas = Channel.find_by_id(@channel_id)
		if (@datas && (@datas.user_id == @user_id || current_user.role == 1))
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
			@id = CGI.escapeHTML(params[:id]).to_i
			@channel_id = CGI.escapeHTML(params[:channel_id])
			@user_id = current_user.id
			@channel = Channel.find_by_id(@channel_id)
			@message = Messages.find_by_id(@id)
			if (@channel && (@channel.user_id == current_user.id || current_user.role == 1 || @message.user_id == current_user.id))
				@message.destroy
				render html: "1"
				return 
			else
				render html: "error-fobidden", :status => :unauthorized
			end
		end
	end
	def removeMessage
		if (!params[:id])
			render html: "error-fobidden", :status => :unauthorized
			return
		end
		@id = CGI.escapeHTML(params[:id]).to_i
		@message = Messages.find_by_id(@id)
		if (@message)
			if (@message.user_id == current_user.id || current_user.role == 1)
				@message.destroy
				render html: "1"
				return
			end
		end
		render html: "error-fobidden", :status => :unauthorized
		return
	end
	def UpdateChannelKey
		if (!params[:id] || !params[:key])
			render html: "error-forbidden", :status => :unauthorized
			return
		else
			@id = CGI.escapeHTML(params[:id]).to_i
			@key = CGI.escapeHTML(params[:key])
			@user_id = current_user.id
			@datas = Channel.find_by_id(@id)
			if (@datas && (@datas.user_id == current_user.id || current_user.role == 1))
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
		@channelId = CGI.escapeHTML(params[:channelId]).to_i
		@user_id = current_user.id
		@datas = Channel.find_by_id(@channelId)
		if (@datas && (@datas.user_id == current_user.id || current_user.role == 1))
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
		@id = CGI.escapeHTML(params[:id]).to_i
		@user_id = current_user.id
		@datas = Channel.find_by_id(@id)
		if (@datas)
			if (@datas.user_id == @user_id || current_user.role == 1)
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
		@newAdmin = CGI.escapeHTML(params[:newAdmin])
		@user_id = current_user.id
		@channel_id = CGI.escapeHTML(params[:channel_id]).to_i
		@datas = Channel.find_by_id(@channel_id)
		@user_info = User.find_by_nickname(@newAdmin)
		if (@datas && (@datas.user_id == @user_id || current_user.role == 1))
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
			@id = CGI.escapeHTML(params[:id]).to_i
			@key = CGI.escapeHTML(params[:key])
			@user_id = current_user.id
			@channel = Channel.find_by_id_and_key(@id, @key)
			if (@channel)
				@datas = Messages.where(["target_id = ? AND message_type = ?", @id, '1'])
				@ret = Array.new
				@is_admin = (@channel.user_id == @user_id || current_user.role == 1) ? 1 : 0
				 @datas.each do |element|
					if (hasSanction(current_user.id, element.user_id, 3) == false)
						@tmp = User.find_by_id(element.user_id)
						@own = element.user_id == current_user.id ? 1 : 2
						@ret.push({"id" => element.id, "content" => element.message, "date" => element.create_time.strftime("%d/%m/%Y"), "author" => @tmp.nickname, "guild" => (@tmp.guild_id ? @tmp.guild.name : ""), "author_id" => element.user_id, "admin" => @is_admin, "own" => 1})
					end
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
		@type = CGI.escapeHTML(params[:type]).to_i
		@channel_id = CGI.escapeHTML(params[:id]).to_i
		@datas = Sanctions.where(user_id: @channel_id, sanction_type: @type).all()
		@channel = Channel.find_by_id(@channel_id)
		if (@datas && @channel && (@channel.user_id == current_user.id || current_user.role == 1))
			@ret = Array.new
			@datas.each do |element|
				if (element.end_time > Time.now.to_i)
					@tmp = User.find_by_id(element.target_id)
					@ret.push({"id" => element.id, "nickname" => @tmp.nickname, "sanction_type" => element.sanction_type})
				end
			end
			render json: @ret
			return
		end
	end
	def addSanction
		if (!params[:id] || !params[:nickname] || !params[:time] || !params[:type] || !safestr(params[:id]) || !safestr(params[:nickname]) || !safestr(params[:time]) || !safestr(params[:type]))
			render html: "error-forbidden", :status => :unauthorized
			return
		end
		@channel_id = CGI.escapeHTML(params[:id]).to_i
		@nickname = CGI.escapeHTML(params[:nickname])
		@type = CGI.escapeHTML(params[:type]).to_i
		@time = CGI.escapeHTML(params[:time]).to_i
		@datas = Channel.find_by_id(@channel_id)
		@user_datas = User.find_by_nickname(@nickname)
		if (@datas && (@datas.user_id == current_user.id || current_user.role == 1))
			if (!@user_datas || @user_datas.id == current_user.id)
				render html: "2"
				return
			end
			Sanctions.create(:sanction_type=> @type,:user_id=> @channel_id, :target_id=> @user_datas.id, :end_time=> (Time.now.to_i + @time), :create_time=> Date.today)
			render html: "1"
			return
		end
		render html: "error-forbidden", :status => :unauthorized
		return
	end
	def removeSanction
		if (params[:id])
			@id = CGI.escapeHTML(params[:id]).to_i
			@sanction = Sanctions.find_by_id(@id)
			@channel = @sanction ? Channel.find_by_id(@sanction.user_id) : -1
			if (@channel != -1 && @channel && (current_user.id == @channel.user_id || current_user.role == 1))
				@sanction.destroy
				render html: "1"
				return
			end
		end
		render html: "error-forbidden", :status => :unauthorized
		return
	end
	def privateConversationGet
		if (!params[:target_id])
			render html: "error-forbidden", :status => :unauthorized
			return
		end
		@user_id = current_user.id
		@target_id = CGI.escapeHTML(params[:target_id]).to_i
		@messages = Messages.where({user_id: current_user.id, target_id: @target_id, message_type: 2}).all.or(Messages.where({user_id: @target_id, target_id: current_user.id, message_type: 2}).all)
		if (@messages)
			@ret = Array.new
			@messages.each do |element|
				@tmp = User.find_by_id(element.user_id)
				if (Sanctions.where({user_id: @user_id,target_id: @target_id,sanction_type: 3}).count == 0)
					@ret.push({"id" => element.id, "author" => @tmp.nickname, "author_id" => element.user_id, "guild" => (@tmp.guild_id ? @tmp.guild.anagramme : ""), "block" => (element.user_id != current_user.id ? 1 : 2), "content" => element.message, "date" => element.create_time.strftime("%d/%m/%Y"), "admin" => (element.user_id == current_user.id ? 1 : 2)})
				end
			end
			render json: @ret
			return
		end
		render html: "error-forbidden", :status => :unauthorized
		return
	end
	def privateConversationSend
		if (!params[:message] || !params[:target_id])
			render html: "error-forbidden", :status => :unauthorized
			return
		end
		@target_id = CGI.escapeHTML(params[:target_id])
		@message = CGI.escapeHTML(params[:message])
		if (@message.length == 0 || @message.length > 90)
			render html: "error-forbidden", :status => :unauthorized
			return
		end
		@date = Date.today
		Messages.create(:user_id=> current_user.id, :create_time=> @date, :message=> @message, :target_id=> @target_id, :message_type=> 2)
		render html: "1"
		return
	end
	def privateConversationInit
		if (!params[:username])
			render html: "error-forbidden", :status => :unauthorized
			return
		end
		@username = CGI.escapeHTML(params[:username])
		@datas = User.find_by_nickname(@username)
		if (@datas)
			if (current_user.id == @datas.id)
				render html: "3"
				return
			end
			@ret = {"id" => @datas.id, "nickname" => @datas.nickname}
			render json: @ret
			return
		end
		render html: "2"
		return
	end
	def blockUser
		if (!params[:user_id])
			render html: "error-forbidden", :status => :unauthorized
			return
		end
		@user_id = CGI.escapeHTML(params[:user_id]).to_i
		if (@user_id == current_user.id)
			render html: "2"
			return
		end
		Sanctions.create(:sanction_type=> 3, :user_id=> current_user.id, target_id: @user_id, :create_time=> Date.today, :end_time => 999999999)
		render html: "1"
		return
	end
	def unblockUser
		if (!params[:user_id])
			render html: "error-forbidden", :status => :unauthorized
			return
		end
		@user_id = CGI.escapeHTML(params[:user_id]).to_i
		@datas = Sanctions.where({sanction_type: 3, user_id: current_user.id, target_id: @user_id}).destroy_all
		render html: "1"
		return
	end
	def profilGet
		if (!params[:user_id])
			render html: "error-forbidden", :status => :unauthorized
			return
		end
		@user_id = CGI.escapeHTML(params[:user_id]).to_i
		@datas = User.find_by_id(@user_id)
		if (@datas)
			@guild = @datas.guild_id != -1 ? Guild.find_by_id(@datas.guild_id) : -1
			@own = @user_id == current_user.id ? 1 : 0
			@stats = @datas.stat
			@ret = {"id" => @user_id, "username" => @datas.nickname, "image" => @datas.image, "guild" => @guild, "stats" => @stats, "own" => @own}
			render json: @ret
			return
		end
		render html: "error-forbidden", :status => :unauthorized
		return
	end
	def getPrivateMessages
		@tmp = Messages.where({user_id: current_user.id, message_type: 2}).all.or(Messages.where({target_id: current_user.id, message_type: 2}).all)
		@sanctions =  Sanctions.where({user_id: current_user.id, sanction_type: 3})
		@messages = Array.new
		@tmp.each do |element|
			@datas = element.user_id == current_user.id ? User.where({id: element.target_id}).select("id", "image", "nickname").first : User.where({id: element.user_id}).select("id", "image", "nickname").first
			if (!findInArrayObj(@messages, @datas.nickname))
				if (hasSanction(current_user.id, @datas.id, 3) == false)
					@messages.push({"image" => @datas.image, "nickname" => @datas.nickname, "target_id" => @datas.id, "blocked" => 1})
				end
			end
		end
		@sanctions.each do |element|
			@datas = User.where({id: element.target_id}).select("nickname", "image", "id")
			if (!findInArrayObj(@messages, @datas.nickname))
				@messages.push({"image" => @datas.image, "nickname" => @datas.nickname, "target_id" => @datas.id, "blocked" => 2})
			end
		end
		render json: @messages
	end
end