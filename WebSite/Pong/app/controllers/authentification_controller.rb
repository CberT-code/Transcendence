require 'net/http'
require 'oauth2'

class AuthentificationController < ApplicationController
	def connexion
		redirect_to "https://api.intra.42.fr/oauth/authorize?client_id=eda6adb82931c26dbd5380defcf580d98ddc861b2892d86960abab3adc4f75c9&redirect_uri=http%3A%2F%2Flocalhost%2Fauthentification&response_type=code"
	end
	def responseAuth
		@code = params[:code]
		if !@code.nil?

			
			uid = "eda6adb82931c26dbd5380defcf580d98ddc861b2892d86960abab3adc4f75c9"
			secret = "2c6edb43028a06220cb42a2ea9256a011f81443c76457818eb2b2d75e4125039"
			# Create the client with your credentials
			client = OAuth2::Client.new(uid, secret, site: "https://api.intra.42.fr")

			token = client.client_credentials.get_token

			render html: token
		else
			render 'errors/404', :status => '404'
		end
	end
end