Rails.application.routes.draw do
	root to: 'pages#home'
	get '/bonjour(/:name)', to: 'pages#salut', as: 'salut'
	get '/authentification', to: 'users/omniauth_callbacks#marvin', as: 'marvin'
	get '/connexion', to: 'authentification#connexion', as: 'connexion'

end