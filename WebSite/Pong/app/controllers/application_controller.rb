require "cgi"

def safestr(string)
	if (string !~ /[!@#$%^&*()_+{}\[\]:;'"\/\\?><.,]/)
		return true;
	else
		return false;
	end
end

class ApplicationController < ActionController::Base
	protect_from_forgery with: :exception
end

