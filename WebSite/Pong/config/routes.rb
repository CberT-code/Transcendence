Rails.application.routes.draw do
	get '/lol', to: 'pages#home'
	devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }
	root to: 'pages#home'
	get '/test', to: 'pages#test', as: 'PONGv1'
	get '/bonjour(/:name)', to: 'pages#salut', as: 'salut'
	post '/pong' =>'game#positions'
	devise_scope :user do
		delete 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session_path
	  end
	mount ActionCable.server => '/cable'
end
