class WarsController < ApplicationController
	before_action do |sign_n_out|
		if !user_signed_in?
			render 'pages/not_authentificate', :status => :unauthorized
		end
		@guild = Guild.find_by_id(current_user.guild_id);
		@admin = (current_user.role == 1 || @guild.id_admin == current_user.id || (@guild.officers.include?current_user.id)) ? 1 : 0;
	end
	def index
		if (@guild.id == -1 || (War.where('(guild_id1 = ? or guild_id2 = ?) and status = ?', @guild.id, @guild.id, 1).count != 0))
			render html: "error-forbidden";
		end
		@wars_history = War.where('(guild_id1 = ? or guild_id2 = ?) and status = ?', @guild.id, @guild.id, 3);
		@wars_request = War.where('(guild_id1 = ? or guild_id2 = ?) and (status = ? or status = ?)', @guild.id, @guild.id, 0, 1);
		@request_sent = War.where('(guild_id1 = ?) and (status = ?)', @guild.id, 0);
	end
	def new
		if (@admin == 0) then
			render 'pages/not_authentificate', :status => :unauthorized
		end
		@wars = History.new
		@list_guild = Guild.where('nbmember >= ?', 5);
		@list_tournament = Tournament.all();
	end
	def edit
		@war = War.find_by_id(params[:id]);
		@team = @war.guild_id1 == @guild.id ? @war.team1 : @war.team2 ;
		if (@admin && @war.status == 1)
			@available = User.where('guild_id = ? and available = ?', current_user.guild_id, true)
			@notavailable = User.where('guild_id = ? and available = ?', current_user.guild_id, false)
		else
			render html: "error-forbidden";
		end
	end
	def show
		@war = War.find_by_id(params[:id]);

		@date = DateTime.current
		@date = @date.change(hour: 17)
		# @war.update(start: DateTime.current + 1.minutes, end: @date + 2.days)
		# @war.update(end: @date + 1.hours)
		@startdays = ((@war.start.to_date) - DateTime.current.to_date).to_i;
		@starthours = ((@war.start.to_i) - DateTime.current.to_i).to_i;
		@enddays = ((@war.end.to_date) - DateTime.current.to_date).to_i;
		@endhours = ((@war.end.to_i) - DateTime.current.to_i).to_i;


		@guild1 = Guild.find_by_id(@war.guild_id1);
		@guild2 = Guild.find_by_id(@war.guild_id2);
		@inwars = War.where('(guild_id1 = ? or guild_id2 = ?) and (status = ? or status = ?)', current_user.guild_id, current_user.guild_id, 1, 2)
		@wars_history = History.where('war_id = ?', @war.id);
		@list_users1 = User.where(id: @war.team1);
		@list_users2 = User.where(id: @war.team2);
	end
	def update
		@war = War.find_by_id(params[:war_id]);
		@guild1 = Guild.find_by_id(@war.guild_id1);
		if (!@guild1.war_id && !@guild.war_id)
			if (@admin && @war && @war.guild_id2 == @guild.id && @war.status == 0)
				@guild.update({war_id: @war.id});
				@guild1.update({war_id: @war.id});
				@war.update({'status': 1});
			else
				render html: "error-accept"
			end
		end
		render html: @war.id
	end
	def destroy
		@war = War.find_by_id(params[:war_id]);
		if (@admin && @war && (@war.guild_id1 == @guild.id || @war.guild_id2 == @guild.id) && @war.status == 0)
			@war.destroy;
		else
			render html: "error-delete"
		end
		render html: "ok"
	end
	def add
		@user = User.find_by_id(params[:id]);
		@war = War.where('(guild_id1 = ? or guild_id2 = ?) and status = ?', @user.guild_id, @user.guild_id, 1);
		@team = @war[0].guild_id1 == @user.guild_id ? @war[0].team1 : @war[0].team2 ;
		if (@team != nil)
			if (@team.include? @user.id)
				render html: '1';
			elsif (@team.count >= @war[0].players)
				render html: '2';
			else
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
		@war = War.where('(guild_id1 = ? or guild_id2 = ?) and status = ?', @user.guild_id, @user.guild_id, 1);
		@team = @war[0].guild_id1 == @user.guild_id ? @war[0].team1 : @war[0].team2 ;
		if (!(@war[0].team1.include? @user.id) && !(@war[0].team2.include? @user.id))
			render html: '1';
		else
			@team.delete(@user.id);
			@war[0].save
			render html: '0';
		end
	end
	def search
		if (params[:points] == "null")
			if (params[:players] == "null")
				@list_guild = Guild.where("LOWER(name) LIKE LOWER(?)", params[:search] + "%");
			elsif (params[:search] == "")
				@list_guild = Guild.where("nbmember >= ?", params[:players]);
			else
				@list_guild = Guild.where("nbmember >= ? and LOWER(name) LIKE LOWER(?)", params[:players], params[:search] + "%");
			end
		else
			if (params[:players] == "null" && params[:search] == "") 
				@list_guild = Guild.where("points >= ?", params[:points]);
			elsif (params[:players] == "null")
				@list_guild = Guild.where("LOWER(name) LIKE LOWER(?) and points >= ?", params[:search] + "%", params[:points]);
			elsif (params[:search] == "")
				@list_guild = Guild.where("nbmember >= ? and points >= ?", params[:players], params[:points]);
			else
				@list_guild = Guild.where("nbmember >= ? and LOWER(name) LIKE LOWER(?) and points >= ?", params[:players], params[:search] + "%", params[:points]);
			end
		end
		@ret = Array.new
		@list_guild.each do |guild|
			if (guild.id != current_user.guild_id)
				@ret.push(["id" => guild.id, "name" => guild.name, "nbmember" => guild.nbmember, "points" => guild.points])
			end
		end
		render json: @ret
	end
	def create

		if (params[:points] == "null")
			render html: 'error_1';
		elsif (params[:players] == "null" || (params[:players] != '5' && params[:players] != '10' && params[:players] != '15'))
			render html: 'error_2';
		elsif (params[:players].to_i > @guild.nbmember)
			render html: 'error_9';
		elsif ((params[:date_start].to_date - DateTime.current.to_date).to_i < 2)
			render html: 'error_3';
		elsif ((params[:date_end].to_date - params[:date_start].to_date).to_i < 2)
			render html: 'error_4';
		elsif (!Tournament.find_by_id(params[:tournament_id]))
			render html: 'error_5';
		elsif ((Tournament.find_by_id(params[:tournament_id]).end.to_date - params[:date_end].to_date) < 0)
			render html: 'error_5_2';
		elsif (params[:points] != '1000' && params[:points] != '5000' && params[:points] != '10000')
			render html: 'error_6';
		elsif (params[:points] != '1000' && params[:points].to_i > @guild.points)
			render html: 'error_7';
		elsif (params[:id] == "0")
			puts "POPOPOPOPOPOPOPOPOPOPOPOOPOPOPOPOPOPOPOPOPOPOPOPOPOPOPOPOPOPOPOPOOPOPOPOPOPOPOPOPOPOPOPO"
			puts Tournament.find_by_id(params[:tournament_id]).end.to_date;
			puts  params[:date_end].to_date;
			puts (Tournament.find_by_id(params[:tournament_id]).end.to_date - params[:date_end].to_date)
			if (params[:points].to_i > 1000)
				@list_guild = Guild.where("nbmember >= ? and points >= ? and war_id = NULL", params[:players], params[:points]);
			else
				@list_guild = Guild.where("nbmember >= ? and war_id IS NULL", params[:players]);
			end
			puts "count";
			puts @list_guild.count;
			if (@list_guild.count <= 1)
				render html: 'error_8';
			else
				@id = rand(@list_guild.count);
				@guildattack = @list_guild[@id];
				while (@guildattack == current_user.guild_id || @id == 0)
					puts @id;
					@id = rand(@list_guild.count);
					@guildattack = @list_guild[@id];
				end
				@war = War.new;
				@war.update({guild_id1: current_user.guild_id, guild_id2: @guildattack.id, start: params[:date_start], end: params[:date_end], points: params[:points], players: params[:players], tournament_id: params[:tournament_id]});
				@war.save;
			end
		else
			@id = params[:id];
			if ((params[:points] > 1000 && params[:points] > Guild.find_by_id(@id).points) || params[:players] > Guild.find_by_id(@id).nbmember)
				render html: 'error_10';
			end
			@war = War.new;
			@war.update({guild_id1: current_user.guild_id, guild_id2: @id, start: params[:date_start], end: params[:date_end], points: params[:points], players: params[:players], tournament_id: params[:tournament_id]});
			@war.save;
		end
	end
end