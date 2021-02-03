Rails.application.routes.draw do
	root to: 'pages#home'
	get '/bonjour(/:name)', to: 'pages#salut', as: 'salut'
	get '/authentification', to: 'authentification#responseAuth', as: 'responseAuth'
	get '/connexion', to: 'authentification#connexion', as: 'connexion'
end
