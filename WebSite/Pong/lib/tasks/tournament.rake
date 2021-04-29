namespace :tournament do
  desc "TODO"
  task statustournament: :environment do
	ActiveRecord::Base.establish_connection(:adapter  => "postgresql", :host => 'postgresql', :port => '5432', :database => 'pong_development', :username => 'postgres', :password => 'password')
	Tournament.connection
	Tournament.statustournament
  end

end
