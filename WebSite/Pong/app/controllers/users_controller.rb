class UsersController < ApplicationController
	skip_before_action :verify_authenticity_token

	before_action do |sign_n_out|
		start_conditions()
		History.clean_list(-1, current_user)
	end

	before_action :otp_login, only: [:show, :index]

	def otp_login
		if @me.otp_required_for_login && @me.locked
			render "/pages/otp"
		end
	end

	def enable_otp
		me = User.find_by_id(params[:id])
		if me.nil?
			render json: {status: "error", info: "user not found"}
		elsif me.otp_required_for_login
			render json: {status: "error", info: "OTP already setup, disable it first"}
		else
			issuer = 'Transcendence'
			label = "Pong! - #{me.nickname}"
			me.otp_secret = User.generate_otp_secret
			me.save!
			
			render json: {status: "ok", info: me.otp_provisioning_uri(label, issuer: issuer)}
		end
	end

	def confirm_otp
		user = User.find_by_id(params[:id])
		if !user
			render json: {status: "error", info: "user not found"}
		elsif user.otp_required_for_login
			render json: {status: "error", info: "OTP already setup, disable it first"}
		elsif params[:otp] == user.current_otp
			user.update(otp_required_for_login: true)
			render json: {status: "ok", info: "OTP setup!"}
		else
			render json: {status: "error", info: "OTP confirmation failed, please retry"}
		end
	end

	def disable_otp
		user = User.find_by_id(params[:id])
		if !user
			render json: {status: "error", info: "user not found"}
		elsif !user.otp_required_for_login
			render json: {status: "error", info: "No OTP enabled, are you f*cking around with hidden buttons?"}
		elsif params[:otp] == user.current_otp
			user.update(otp_required_for_login: false)
			render json: {status: "ok", info: "OTP succesfully disabled"}
		else
			render json: {status: "error", info: "OTP confirmation failed, please retry"}
		end
	end

	def index
		if (@me.role == 1)
			@Users = User.where({deleted: false});
		else
			render html: "error-forbidden", :status => :unauthorized
		end
	end

	def show
		if (params.has_key?(:id))
			@user = User.where({id: params[:id]}).limit(1).select("id", "nickname", "banned", "deleted", "available", "image", "guild_id", "stat_id", "friends").first
			if (@user == nil && params[:id] != "0")
				render "/pages/error-404"
				return
			else 
				@user = current_user
			end
		else
			@user = current_user
		end
		@user_stat = @user.stat;
		@guild = @user.guild;
		@current = @me.id == @user.id ? 1 : 0;
		@histories = History.where(['host_id = ? or opponent_id = ?', @user.id, @user.id]).order(:created_at).reverse;
		@date = DateTime.new(1905,1,1,1,1,1);
		@tournament = Array.new
		Tournament.all.each do |tr|
			if tr.available && tr.playerIsRegistered(@user.id) && tr.playerIsRegistered(@me.id)
				@tournament.push(tr)
			end
		end

	end

	def update
		@user = User.find_by_id(params[:id])
		@current = current_user.id == @user.id ? 1 : 0;
		if (@current == 1 || @admin == 1 )
			if (params.has_key?(:checked) && (params[:checked] == "true" || params[:checked] == "false"))
				User.find_by_id(@user.id).update({available: params[:checked]});
				render html: "success";
			elsif (params.has_key?(:username))
				if (!safestr(params[:username]))
					render html: "special-characters"
				elsif (params[:username] == "")
					render html: "error-incomplete";
				elsif (params[:username].length > 20)
					render html: "error-size";
				elsif (!User.find_by_nickname(params[:username]))
					@user.update({nickname: params[:username]});
					render html: "success";
				else
					render html: "error-username_exist";
				end
			end
		else
			render html: "error-forbidden";
		end
	end

	def destroy
		@user = User.find_by_id(params[:id])
		@current = current_user.id == @user.id ? 1 : 0;
		if (@current == 1 || @admin == 1)
			if (@user.guild_id)
				render html: "error-inguild";
			else
				@nb = User.where(["email LIKE '%%@unknown.fr' "]).count
				@user.update({nickname: "unknown", image: nil, email: @nb.to_s + "@unknown.fr", deleted: true})
				@user.save
				if (@current == 1)
					sign_out current_user
				end
			end
		else
			render html: "error-forbidden";
		end
	end

	def addfriend
		@user = User.find_by_id(params[:id]);
		if (!(@me.friends.include?@user.id) && @user.id != current_user.id)
			@me.friends.push(@user.id)
			@me.save
			render html: 1;
		else
			render html: 2;
		end
	end

	def delfriend
		@user = User.find_by_id(params[:id]);
		if ((@me.friends.include?@user.id) && (@user.id != current_user.id))
			@me.friends.delete(@user.id)
			@me.save
			render html: 1;
		else
			render html: 2;
		end
	end
	def ban
		@user = User.find_by_id(params[:id]);
		if (@user.guild_id)
			render html: "error-inguild";
		else
			if (@me.role == 1)
				if (@user.banned == true)
					render html: "error-banned"
				else
					@user.update({banned: true})
					render html: "success"
				end
			else
				render html: "error_admin"
			end
		end
	end
	def unban
		@user = User.find_by_id(params[:id]);
		if (@me.role == 1)
			if (@user.banned == false)
				render html: "error-unbanned"
			else
				@user.update({banned: false})
				render html: "success"
			end
		else
			render html: "error_admin"
		end
	end
end
