namespace :war do
  desc "TODO"
  task :checktime =>  [:environment] do
	ActiveRecord::Base.establish_connection(:adapter  => "postgresql", :host => 'postgresql', :port => '5432', :database => 'pong_development', :username => 'postgres', :password => 'password')
	# require 'application.rb'
	# puts ENV 	
		War.connection
		puts "toto"
		War.teste
	end
end
