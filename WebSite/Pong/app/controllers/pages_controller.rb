class PagesController < ApplicationController

	before_action :signin, except: [:ban]
	before_action :otp_login, except: [:otp_check, :ban]

	def otp_login
		if @me.locked
			render "/pages/otp"
		end
	end

	def salut
		@name = params[:name]
	end

	def signin
		if !user_signed_in?
			render 'pages/not_authentificate', :status => :unauthorized
		end
	end
	def ban
	end

	def connexion
	end

	def otp_check
		if !@me
			render json: {status: "error", info: "Invalid user"}
		elsif !@me.locked
			render json: {status: "ok", info: "User has already validated OTP"}
		elsif !@me.otp_required_for_login
			@me.locked = false
			@me.save!
			render json: {status: "ok", info: "User hasn't enabled OTP"}
		elsif @me.current_otp == params[:otp]
			@me.locked = false
			@me.save!
			render json: {status: "ok", info: "It's an older code, sir, but it checks out"}
		else
			render json: {status: "error", info: "Bad OTP"}
		end
	end

	def ladder
		@t_users = TournamentUser.where({tournament_id: 1}).sort_by { |u| u.elo}.reverse
	end

	def home
		# @session = session["devise.marvin_data"]	
	end

end