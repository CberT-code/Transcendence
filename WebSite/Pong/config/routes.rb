Rails.application.routes.draw do
	devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }
	root to: "pages#home"
	devise_scope :user do
    	delete "sign_out", :to => "devise/sessions#destroy", :as => :destroy_user_session_path
	end
	get "/account", to: "pages#account"
	get "/tchat", to: "pages#tchat"
	get "/play", to: "pages#play"
	#get '/play', to: 'histories#matchmaking', as 'PONGv1'
	get "/guilds", to: "pages#guilds"
	get "/guilds_new", to: "pages#guilds_new"
	get "/tournaments", to: "pages#tournaments"
	get '/test', to: 'pages#test', as: 'PONGv1' #to be removed
	#resources :histories

	post "/account/delete", to: "post#deleteAccount"
	post "/account/changeusername", to: "post#ChangeUsername"
	post "/account/history", to: "post#HistoryUser"
	post "/guilds/listguilds", to: "post#ListGuilds"
	post "/guilds/guildcreate", to: "post#GuildsCreate"
	post "/guilds/guildquit", to: "post#GuildQuit"
end
