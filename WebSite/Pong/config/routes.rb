Rails.application.routes.draw do
	devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }
	root to: 'pages#home'
	get '/test', to: 'pages#test', as: 'PONG'
	get '/bonjour(/:name)', to: 'pages#salut', as: 'salut'
	devise_scope :user do
		delete 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session_path
	  end
end