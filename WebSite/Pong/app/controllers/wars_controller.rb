class WarsController < ApplicationController
	# serialize :team1, Array
	# serialize :team2, Array
	before_action do |sign_n_out|
		if !user_signed_in?
			render 'pages/not_authentificate', :status => :unauthorized
		end
		@guild = Guild.find_by_id(current_user.id_guild);
		@admin = (current_user.role == 1 || @guild.id_admin == current_user.id) ? 1 : 0;

	end
	def index
		if (@guild.id == -1 || (War.where('(id_guild1 = ? or id_guild2 = ?) and status = ?', @guild.id, @guild.id, 1).count != 0))
			render html: "error-forbidden";
		end
		@wars_history = War.where('(id_guild1 = ? or id_guild2 = ?) and status = ?', @guild.id, @guild.id, 3);
		@wars_request = War.where('(id_guild1 = ? or id_guild2 = ?) and (status = ? or status = ?)', @guild.id, @guild.id, 0, 1);
	end
	def new
		if (@admin == 0) then
			render 'pages/not_authentificate', :status => :unauthorized
		end
		@wars = History.new
		@list_guild = Guild.where('nbmember >= ?', 2);
	end
	def create
	end
	def edit
		@war = War.find_by_id(params[:id]);
		@team = @war.id_guild1 == @guild.id ? @war.team1 : @war.team2 ;
		if (@admin)
			@available = User.where('id_guild = ? and available = ?', current_user.id_guild, true)
			@notavailable = User.where('id_guild = ? and available = ?', current_user.id_guild, false)
		else
			render html: "error-forbidden";
		end
	end
	def show
		@war = War.find_by_id(params[:id]);

		@date = DateTime.current + 2.days
		@date = @date.change(hour: 17)
		@war.update(start: @date, end: @date + 2.days)
		
		
		@datedays = ((@war.start.to_date) - DateTime.current.to_date).to_i;
		@datehours = ((@war.start.to_i) - DateTime.current.to_i).to_i;

		@guild1 = Guild.find_by_id(@war.id_guild1);
		@guild2 = Guild.find_by_id(@war.id_guild2);
		@inwars = War.where('(id_guild1 = ? or id_guild2 = ?) and (status = ? or status = ?)', current_user.id_guild, current_user.id_guild, 1, 2)
		@wars_history = History.where('id_war = ?', @war.id);
		@list_users1 = User.where('id_guild = ?', @guild1.id);
		@list_users2 = User.where('id_guild = ?', @guild2.id);
	end
	def update
		@war = War.find_by_id(params[:id_war]);
		if (@admin && @war && @war.id_guild2 == @guild.id && @war.status == 0)
			@war.update({'status': 1});
		else
			render html: "error-accept"
		end
		render html: @war.id
	end
	def destroy
		@war = War.find_by_id(params[:id_war]);
		if (@admin && @war && (@war.id_guild1 == @guild.id || @war.id_guild2 == @guild.id) && @war.status == 0)
			@war.destroy;
		else
			render html: "error-delete"
		end
		render html: "ok"
	end
	def add
		@user = User.find_by_id(params[:id]);
		@war = War.where('(id_guild1 = ? or id_guild2 = ?) and status = ?', @user.id_guild, @user.id_guild, 1);
		@team = @war[0].id_guild1 == @user.id_guild ? @war[0].team1 : @war[0].team2 ;
		if (@team != nil)
			if (@team.include? @user.id)
				render html: '1';
			elsif (@team.count >= @war[0].players)
				render html: '2';
			else
				puts "WAIT FOR THAT"
				@team.push(@user.id) ;
				render html: '0'
			end
		else
			@war[0].update(team2: [@user.id]) ;
			render html: '0'
		end
			@war[0].save
	end
	def remove
		@user = User.find_by_id(params[:id]);
		@war = War.where('(id_guild1 = ? or id_guild2 = ?) and status = ?', @user.id_guild, @user.id_guild, 1);
		@team = @war[0].id_guild1 == @user.id_guild ? @war[0].team1 : @war[0].team2 ;
		if (!(@war[0].team1.include? @user.id) && !(@war[0].team2.include? @user.id))
			render html: '1';
		else
			@team.delete(@user.id);
			@war[0].save
			render html: '0';
		end
	end
end