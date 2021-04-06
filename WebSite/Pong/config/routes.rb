Rails.application.routes.draw do
	devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }
	root to: "pages#home"
	devise_scope :user do
    	delete "sign_out", :to => "devise/sessions#destroy", :as => :destroy_user_session_path
	end
	# get "/account", to: "pages#account"
	get "/tchat", to: "pages#tchat"
	get "/play", to: "pages#play"
	get "/501", to: "error#403"

	# post "/account/delete", to: "post#deleteAccount"
	# post "/account/changeusername", to: "post#ChangeUsername"
	# post "/account/history", to: "post#HistoryUser"

	# post "/guilds/guildcreate", to: "post#GuildsCreate"
	post "/guilds/join", to: "guilds#join"
	
	resources :guilds
	resources :tournaments
	resources :users
	resources :wars
	post "/wars/add", to: "wars#add"
	post "/wars/remove", to: "wars#remove"
	post "/wars/search", to: "wars#search"
	post "/guilds/search", to: "guilds#search"
	post "/guilds/ban", to: "guilds#ban"
	post "/guilds/unban", to: "guilds#unban"
	post "/guilds/officer", to: "guilds#officer"
	post "/guilds/anagramme", to: "guilds#anagramme"
end
