Rails.application.routes.draw do
	root to: 'pages#home'
	get '/bonjour(/:name)', to: 'pages#salut', as: 'salut'
end
