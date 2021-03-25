Rails.application.routes.draw do
	devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }
	root to: "pages#home"
	devise_scope :user do
    	delete "sign_out", :to => "devise/sessions#destroy", :as => :destroy_user_session_path
	end
	# get "/account", to: "pages#account"
	get "/play", to: "pages#play"

	# post "/account/delete", to: "post#deleteAccount"
	# post "/account/changeusername", to: "post#ChangeUsername"
	# post "/account/history", to: "post#HistoryUser"

	# post "/guilds/guildcreate", to: "post#GuildsCreate"
	post "/guilds/join", to: "guilds#join"
	post "/tchat/channel/create", to: "tchat#channelCreate"
	post "/tchat/channel/message/create", to: "tchat#sendMessageChannel"
	get "/tchat/channel/get/:id", to: "tchat#getChannel"
	get "/tchat/channel/message/get/:id/:key", to: "tchat#getChannelMessage"

	resources :guilds
	resources :tournaments
	resources :users
	resources :tchat
end
