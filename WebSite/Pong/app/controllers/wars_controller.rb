class WarsController < ApplicationController
	# serialize :team1, Array
	# serialize :team2, Array
	before_action do |sign_n_out|
		if !user_signed_in?
			render 'pages/not_authentificate', :status => :unauthorized
		end
	end
	def index
		@guild = Guild.find_by_id(current_user.id_guild);
		@admin = (current_user.role == 1 || @guild.id_admin == current_user.id) ? 1 : 0;
		if (@guild.id == -1)
			render html: "error-forbidden";
		end
		puts "wars".classify
		@wars_history = War.where('(id_guild1 = ? or id_guild2 = ?) and status = ?', @guild.id, @guild.id, 2);
		@wars_request = War.where('(id_guild1 = ? or id_guild2 = ?) and (status = ? or status = ?)', @guild.id, @guild.id, 0, 1);
	end
	def new
		@guild = Guild.find_by_id(current_user.id_guild);
		@admin = (current_user.role == 1 || @guild.id_admin == current_user.id) ? 1 : 0;
		if (@admin == 0) then
			render 'pages/not_authentificate', :status => :unauthorized
		end
		@wars = History.new
	end
	def create
	end
	def show
		@war = History.find_by_id(params[:id]);
		@guild1 = Guild.find_by_id(@war.target_1);
		@guild2 = Guild.find_by_id(@war.target_2);
		puts @war.inspect
		puts @guild1.inspect
		@list_users1 = User.where('id_guild = ?', @guild1.id);
		@list_users2 = User.where('id_guild = ?', @guild2.id);
		puts @list_users1.inspect
	end
	def update
	end
	def destroy
	end
	def join
	end
end