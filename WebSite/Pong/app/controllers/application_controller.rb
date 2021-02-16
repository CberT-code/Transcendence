class ApplicationController < ActionController::Base
	protect_from_forgery with: :exception
	ENV['RACK_MINI_PROFILER'] = 'disable'
end