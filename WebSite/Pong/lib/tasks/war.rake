namespace :war do
  desc "TODO"
  task :checktime =>  [:environment] do
	ActiveRecord::Base.establish_connection(:adapter  => "postgresql", :host => 'postgresql', :port => '5432', :database => 'pong_development', :username => 'postgres', :password => 'password')
		War.connection
		War.startwar
		War.endwar
	end
  task :startwartime =>  [:environment] do
	ActiveRecord::Base.establish_connection(:adapter  => "postgresql", :host => 'postgresql', :port => '5432', :database => 'pong_development', :username => 'postgres', :password => 'password')
		War.connection
		War.startwartime
	end
  task :stopwartime =>  [:environment] do
	ActiveRecord::Base.establish_connection(:adapter  => "postgresql", :host => 'postgresql', :port => '5432', :database => 'pong_development', :username => 'postgres', :password => 'password')
		War.connection
		War.stopwartime
	end
end
