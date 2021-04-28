class PagesController < ApplicationController

	before_action do |sign_n_out|
		if !user_signed_in?
			render 'pages/not_authentificate', :status => :unauthorized
		end
		ActionCable.server.broadcast("presence_#{@me.id}", "hello from presence channel")
		puts "action cable just sent a message"
	end

	before_action :otp_login, except: [:otp_check]

	def otp_login
		if @me.locked
			render "/pages/otp"
		end
	end

	def salut
		@name = params[:name]
	end

	def connexion
	end

	def otp_check
		if !@me
			render json: {status: "error", info: "Invalid user"}
		elsif !@me.locked
			render json: {status: "ok", info: "User has already validated OTP"}
		elsif !@me.otp_required_for_login
			@me.update(locked: false)
			render json: {status: "ok", info: "User hasn't enabled OTP"}
		elsif @me.current_otp == params[:otp]
			@me.update(locked: false)
			render json: {status: "ok", info: "It's and older code, sir, but it checks out"}
		else
			render json: {status: "error", info: "Bad OTP"}
		end
	end

	def ladder
		@players = User.all.sort_by { |u| u.elo}.reverse
	end

	def home
		@me = current_user
		
		# @session = session["devise.marvin_data"]	
	end

end