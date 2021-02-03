

class AuthentificationController < ApplicationController
	def connexion
		if !$g_user || !user_signed_in?
			redirect_to "https://api.intra.42.fr/oauth/authorize?client_id=eda6adb82931c26dbd5380defcf580d98ddc861b2892d86960abab3adc4f75c9&redirect_uri=http%3A%2F%2Flocalhost%2Fauthentification&response_type=code"
		end
		if (!(defined?($token)) || !(defined?($client)))
			$client = OAuth2::Client.new(UID, SECRET, site: "https://api.intra.42.fr")
			$token = $client.client_credentials.get_token
		end
	end
end