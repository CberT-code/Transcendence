Rails.application.routes.draw do

	devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }
	root to: 'pages#home'
	get '/test', to: 'pages#test', as: 'PONGv1' #to be removed
	#get '/play', to: 'histories#matchmaking', as 'PONGv1'
	#resources :histories
	devise_scope :user do
		delete 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session_path
	end

	get '/lol', to: 'pages#home' # useless ?
	get '/bonjour(/:name)', to: 'pages#salut', as: 'salut' # useless ?

end
