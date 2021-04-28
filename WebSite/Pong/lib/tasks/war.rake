namespace :war do
  desc "TODO"
  task :checktime =>  [:environment] do
	puts "check des wars start"
	ActiveRecord::Base.establish_connection(:adapter  => "postgresql", :host => 'postgresql', :port => '5432', :database => 'pong_development', :username => 'postgres', :password => 'password')
		War.connection
		War.startwar
		puts "check des wars start"
		War.endwar
		puts "check des wars ended"
	end
  task :startwartime =>  [:environment] do
	ActiveRecord::Base.establish_connection(:adapter  => "postgresql", :host => 'postgresql', :port => '5432', :database => 'pong_development', :username => 'postgres', :password => 'password')
		War.connection
		War.startwartime
		puts "startwartime"
	end
  task :stopwartime =>  [:environment] do
	ActiveRecord::Base.establish_connection(:adapter  => "postgresql", :host => 'postgresql', :port => '5432', :database => 'pong_development', :username => 'postgres', :password => 'password')
		War.connection
		War.stopwartime
		puts "stopwartime"
	end
end
