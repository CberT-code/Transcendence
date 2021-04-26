Rails.application.routes.draw do
	devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }

	root to: "pages#home"

	devise_scope :user do
    	delete "sign_out", :to => "devise/sessions#destroy", :as => :destroy_user_session_path
	end
	# get "/account", to: "pages#account"
	get "/play", to: "pages#play"
	get "/ladder", to: "pages#ladder"
	get "/501", to: "error#403"

	post "/users/enable_otp/:id", to: "users#enable_otp"

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
	post "/tchat/channel/remove", to: "tchat#removeChannel"
	post "/tchat/channel/sanction/create", to: "tchat#addSanction"
	get "/tchat/channel/blocked/:id", to: "tchat#getAdminBlockedUsers"
	get "/tchat/channel/get/:id", to: "tchat#getChannel"
	get "/tchat/channel/get/:id/:key", to: "tchat#getPrivateChannel"
	get "/tchat/channel/message/get/:id/:key", to: "tchat#getChannelMessage"
	get "/tchat/channel/admin/:id", to: "tchat#isChannelAdmin"
	get "/tchat/channel/sanctions/get/:id/:type", to: "tchat#getSanctions"

	post "/tchat/channel/sanction/", to: "tchat#ApplySanction"

	resources :guilds

	resources :tournaments
	post "/tournaments/playerJoin/", to: "tournaments#playerJoin"

	resources :users
	get "/users/status/:id", to: "users#status"
	post "/users/addfriend", to: "users#addfriend"
	post "/users/delfriend", to: "users#delfriend"

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
	post "/histories/run/:id", to: "game#run"
	post "/histories/stop/:id", to: "game#stop"
	post "/histories/find_or_create", to: "matchmaking#find_or_create"
	post "/histories/duel", to: "matchmaking#duel"
	post "/histories/timeout/:id", to: "matchmaking#timeout"
end
