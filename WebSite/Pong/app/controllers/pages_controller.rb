class PagesController < ApplicationController
	if $token.expired?
		$client = OAuth2::Client.new(UID, SECRET, site: "https://api.intra.42.fr")
		$token = $client.client_credentials.get_token
	end
	def salut
		@name = params[:name]
	end
	def connexion
	end
	def home
	end
end