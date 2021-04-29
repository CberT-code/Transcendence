require 'cgi'

class ApplicationController < ActionController::Base
	before_action :configure_permitted_parameters, if: :devise_controller?
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

	protected

	def configure_permitted_parameters
		devise_parameter_sanitizer.permit(:sign_in, keys: [:otp_attempt])
	end
end

