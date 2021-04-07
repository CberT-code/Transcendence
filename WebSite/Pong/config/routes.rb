Rails.application.routes.draw do
	devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }

	root to: "pages#home"

	devise_scope :user do
    	delete "sign_out", :to => "devise/sessions#destroy", :as => :destroy_user_session_path
	end
	# get "/account", to: "pages#account"
	get "/play", to: "pages#play"
	get "/501", to: "error#403"

	# post "/account/delete", to: "post#deleteAccount"
	# post "/account/changeusername", to: "post#ChangeUsername"
	# post "/account/history", to: "post#HistoryUser"

	# post "/guilds/guildcreate", to: "post#GuildsCreate"
	post "/guilds/join", to: "guilds#join"
	post "/tchat/channel/create", to: "tchat#channelCreate"
	post "/tchat/channel/message/create", to: "tchat#sendMessageChannel"
	post "/tchat/channel/message/remove", to: "tchat#removeMessageChannel"
	post "/tchat/channel/user", to: "tchat#userBlockChannel"
	post "/tchat/channel/blocked/:key", to: "tchat#removeBlockedUser"
	post "/tchat/channel/key", to: "tchat#UpdateChannelKey"
	post "/tchat/channel/type", to: "tchat#UpdateChannelType"
	post "/tchat/channel/admin/swap", to: "tchat#exchangeChannelAdmin"
	get "/tchat/channel/blocked/:id", to: "tchat#getAdminBlockedUsers"
	get "/tchat/channel/get/:id", to: "tchat#getChannel"
	get "/tchat/channel/get/:id/:key", to: "tchat#getPrivateChannel"
	get "/tchat/channel/message/get/:id/:key", to: "tchat#getChannelMessage"
	get "/tchat/channel/admin/:id", to: "tchat#isChannelAdmin"

	post "/tchat/channel/sanction/", to: "tchat#ApplySanction"

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
	resources :tchat

	resources :histories
	post "/histories/run/:id", to: "histories#run"
	post "/histories/wait/:id", to: "histories#wait"
end
