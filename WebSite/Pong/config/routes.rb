Rails.application.routes.draw do
	root to: 'pages#home'
	get '/bonjour(/:name)', to: 'pages#salut', as: 'salut'
	get '/authentification', to: 'users/omniauth_callbacks#marvin', as: 'marvin'
	get '/connexion', to: 'authentification#connexion', as: 'connexion'
	devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }
	  devise_scope :user do
		delete "/users/sign_out", to: "devise/sessions#destroy", as: 'sign_out'
	  end
end