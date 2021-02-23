class PostController < ApplicationController
	before_action do |sign_n_out|
		if !user_signed_in?
			render 'pages/not_authentificate', :status => :unauthorized
		end
	end
	def deleteAccount
		Stat.find_by_id(current_user.id_stats).destroy
		User.find_by_id(current_user.id).destroy
		destroy_user_session_path
		render html: "1"
	end
	def ChangeUsername
		if (!User.find_by_nickname(params[:username]))
			User.find_by_id(current_user.id).update({"nickname": params[:username]})
			render html: "1"
		else
			render html: "2"
		end
	end
	def HistoryUser
		@tab = History.where('(target_1 = ? or target_2 = ?) and target_type = ?', current_user.id, current_user.id, 1);
		@tab = @tab.as_json(only: [:target_1, :target_2, :score_target_1, :score_target_2])
		@tab.each do |ta|
			@name = User.find_by_id(ta["target_1"]);
			@name2 = User.find_by_id(ta["target_2"]);
			ta["target_1"] = @name.nickname;
			ta["target_2"] = @name2.nickname;
		end
		render json: @tab
	end
	def ListGuilds
		@tab = Guild.order(:name);
		@tab = @tab.as_json(only: [:name, :description, :id_stats])
		render json: @tab
	end
	def GuildsCreate
		if (params[:guildname] == "")
			render html: 2;
		elsif (params[:guildstory] == "")
			render html: 3;
		elsif (params[:maxmember] != '5' && params[:maxmember] != '10' && params[:maxmember] != '15' )
			render html: 4;
		elsif (Guild.find_by_name(params[:guildname]))
			render html: 5;
		elsif (params[:guildstory].length > 250 )
			render html: 6;
		else
			@guild = Guild.new;
			@stat = Stat.new;
			@stat.save;
			@guild.update({name: params[:guildname], description: params[:guildstory], id_stats: @stat.id, maxmember: params[:maxmember]});
			@guild.nbmember = 1;
			@guild.save;
			User.find_by_id(current_user.id).update({"id_guild": @guild.id});
			render html: 1;
		end
	end
	def GuildQuit
		@user = User.find_by_id(current_user.id);
		@guild = Guild.find_by_id(@user.id_guild);
		if (@guild.nbmember == 1) then
			@stat = Stat.find_by_id(@guild.id_stats);
			@stat.destroy();
			@guild.destroy();
		else
			@guild.update(nbmember: @guild.nbmember - 1);
		end
		@user.update({"id_guild": '-1'});
		render html: 1;
	end
end