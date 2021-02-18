Rails.application.routes.draw do
	devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }
	root to: "pages#home"
	devise_scope :user do
    	delete "sign_out", :to => "devise/sessions#destroy", :as => :destroy_user_session_path
	end
	get "/account", to: "pages#account"
	get "/tchat", to: "pages#tchat"
	get "/play", to: "pages#play"
	get "/guilds", to: "pages#guilds"
	get "/tournaments", to: "pages#tournaments"
	post "/account/delete", to: "post#deleteAccount"
	post "/account/changeusername", to: "post#ChangeUsername"
	post "/account/history", to: "post#HistoryUser"
	post "/guilds/listguilds", to: "post#ListGuilds"
end
