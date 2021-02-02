Rails.application.routes.draw do
	get '/test/', to: 'IndexController#test'
end
