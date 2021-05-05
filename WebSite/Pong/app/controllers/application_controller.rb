require 'cgi'

class ApplicationController < ActionController::Base
	before_action :configure_permitted_parameters, if: :devise_controller?
	before_action do
		@me = current_user
	end
	protect_from_forgery with: :exception

	def safestr(string)
		if (string !~ /[!@#$%^&*()_+{}\[\]:;'"\/\\?><.,]/)
			return true;
		else
			return false;
		end
	end
	def findInArrayObj(array, value)
		array.each do |element|
			if element["nickname"] == value
				return true
			end
		end
		return false
	end
	def safesentence(string)
		if (string !~ /[!@#$%^&*()_+{}\[\]:;'"\/\\?><]/)
			return true;
		else
			return false;
		end
	end
	def hasSanction(user_id, target_id, type)
		@sanctions = Sanctions.where({user_id: user_id, target_id: target_id, sanction_type: type}).all
		@sanctions.each do |sanction|
			if (sanction.end_time >= Time.now.to_i)
				return true
			end
		end
		return false
	end
	def start_conditions()
		if !user_signed_in? 
			render 'pages/not_authentificate', :status => :unauthorized
			return (0)
		elsif @me.deleted == true
			sign_out current_user
			return (0)
		elsif @me.banned == true 
			sign_out current_user
			render "/pages/ban"
			return (0)
		else
			@admin = current_user.role == 1 ? 1 : 0;
			@me = current_user
			return (1)
		end
	end
	def is_number? string
		true if Float(string) rescue false
	end

	protected

	def configure_permitted_parameters
		devise_parameter_sanitizer.permit(:sign_in, keys: [:otp_attempt])
	end
	def after_sign_in_path_for(resource)
		"/#show_user/" + current_user.id.to_s
	  end
end

