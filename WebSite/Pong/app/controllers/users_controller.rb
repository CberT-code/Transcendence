class UsersController < ApplicationController
	skip_before_action :verify_authenticity_token

	before_action do |sign_n_out|
		if !user_signed_in?
			render 'pages/not_authentificate', :status => :unauthorized
		end
		@me = current_user
		@admin = @me.role
	end

	def enable_otp
		me = User.find_by_id(params[:id])
		if me.nil?
			render json: {status: "error", info: "user not found"}
		else
			issuer = 'Transcendence'
			label = "#{issuer}:#{me.email}"
			if me.otp_required_for_login
				puts "\n\nOTP ALREADY IN USE\n\n\n"
			end
			me.otp_required_for_login = true
			me.otp_secret = User.generate_otp_secret
			me.save!
			
			render json: {status: "ok", info: me.otp_provisioning_uri(label, issuer: issuer)}
		end
	end

	def status
		redis = Redis.new(	url:  ENV['REDIS_URL'],
							port: ENV['REDIS_PORT'],
							db:   ENV['REDIS_DB'])
		status = redis.get("player_#{params[:id]}")
		if (status == "static" || status == "up" || status == "down")
			render html: "in_game"
		elsif status != nil
			render html: status
		else
			render html: "offline"
		end
	end

	def index
		@Users = User.where("deleted = ?", FALSE);
	end

	def show
		@user = User.find_by_id(params[:id])
		if (!@user.deleted)
			@user_stat = @user.stat;
			@guild = @user.guild;
			@current = current_user.id == @user.id ? 1 : 0;
			@histories = History.where('host_id = ? or opponent_id = ?', @user.id, @user.id);
			@date = DateTime.new(1905,1,1,1,1,1);
			@tournament = Array.new
			Tournament.all.each do |tr|
				if tr.available && tr.playerIsRegistered(@user.id) && tr.playerIsRegistered(@me.id)
					@tournament.push(tr)
				end
			end
			# @tournament = Tournament.where("(start < ?) OR ('end' > ? AND start < ?)", @date, DateTime.current, DateTime.current);
		else
			render 'error/403', :status => :unauthorized
		end
	end

	def update
		@user = User.find_by_id(params[:id])
		@current = current_user.id == @user.id ? 1 : 0;
		if (@current == 1 || @admin == 1)
			if (params.has_key?(:checked))
				User.find_by_id(@user.id).update({"available": params[:checked]});
				render html: "success";
			elsif (params.has_key?(:username))
				if (!safestr(params[:username]))
					render html: "special-characters"
				elsif (params[:username] == "")
					render html: "error-incomplete";
				elsif (!User.find_by_nickname(params[:username]))
					@user.update({"nickname": params[:username]});
					render html: "success";
				else
					render html: "errorusername_exist";
				end
			end
		else
			render 'error/403', :status => :unauthorized;
		end
	end

	def destroy
		@user = User.find_by_id(params[:id])
		@current = current_user.id == @user.id ? 1 : 0;
		if (@current == 1 || @admin == 1)
			if (@user.guild_id)
				render html: "error-inguild";
			else
				@user.destroy
				redirect_to destroy_user_session_path
			end
		else
			render html: "error-forbidden";
		end
	end

	def addfriend
		@user = User.find(params[:id]);
		if (!(@me.friends.include?@user.id) && @user.id != current_user.id)
			@me.friends.push(@user.id)
			@me.save
			render html: 1;
		else
			render html: 2;
		end
	end

	def delfriend
		@user = User.find(params[:id]);
		if ((@me.friends.include?@user.id) && (@user.id != current_user.id))
			@me.friends.delete(@user.id)
			@me.save
			render html: 1;
		else
			render html: 2;
		end
	end
end
