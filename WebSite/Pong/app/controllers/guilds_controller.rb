class GuildsController < ApplicationController
	before_action do |sign_n_out|
		if !user_signed_in?
			render 'pages/not_authentificate', :status => :unauthorized
		end
	end

	def index
		@guilds = Guild.all.order('name');
	end
	def new
		if (User.find_by_id(current_user.id).id_guild != -1) then
			render 'pages/not_authentificate', :status => :unauthorized
		end
		@guild = Guild.new
	end
	def create
		if (params[:guildname] == "")
			render html: "error-1";
		elsif (params[:guildstory] == "")
			render html: "error-2";
		elsif (params[:maxmember] != '5' && params[:maxmember] != '10' && params[:maxmember] != '15' )
			render html: "error-3";
		elsif (Guild.find_by_name(params[:guildname]))
			render html: "error-4";
		elsif (params[:guildstory].length > 250 )
			render html: "error-5";
		else
			@guild = Guild.new;
			@stat = Stat.new;
			@stat.save;
			@guild.update({name: params[:guildname], description: params[:guildstory], id_stats: @stat.id, maxmember: params[:maxmember]});
			@guild.nbmember = 1;
			@guild.save;
			User.find_by_id(current_user.id).update({"id_guild": @guild.id});
			render html: @guild.id;
		end
	end
	def show
		@guild = Guild.find_by_id(params[:id]);
		@super_admin = current_user.role;
		@user = User.find_by_id(current_user.id);
		@user_guild = User.find_by_id(current_user.id).id_guild;
		@my_guild = @guild.id == @user_guild ? 1 : 0;
		@wars_histories = History.where('(target_1 = ? or target_2 = ?) and target_type = ?', @guild.id, @guild.id, 2);
		@list_users = User.where('id_guild = ?', @guild.id);
		@admin = current_user.id == @guild.id_admin ? 1 : 0;
	end
	def update
		@super_admin = current_user.role;
		@user_admin = User.find_by_id(params[:id_admin]);
		@guild = Guild.find_by_id(@user_admin.id_guild);
		if (@current_user.id_guild == @guild.id || @super_admin == 1)
			@guild.update({'id_admin': @user_admin.id});
		else
			render html: "error-badguild";
		end
		render html: @guild.id;
	end
	# destroy need a solution to kill user if it's the user or the super admin
	def destroy
		@user = User.find_by_id(params[:id]);
		@guild = Guild.find_by_id(@user.id_guild);
		@admin = (current_user.role == 1 || @guild.id_admin == current_user.id) ? 1 : 0;

		if (@user.id_guild != -1 && @admin == 1) then
			if (@guild.id_admin == @user.id && @guild.nbmember != 1)
				render html: "error-admin";
			else
				if (@guild.nbmember == 1 ) then
					@stat = Stat.find_by_id(@guild.id_stats);
					@stat.destroy();
					@guild.destroy();
				else
					@guild.update(nbmember: @guild.nbmember - 1);
				end
				@user.update({"id_guild": '-1'});
				render html: 1;
			end
		elsif (@user.id == current_user.id)
			@guild.update(nbmember: @guild.nbmember - 1);
			@user.update({"id_guild": '-1'});
			render html: 1;
		else
			render html: 1;
		end
	end
	def join
		@user = User.find_by_id(current_user.id);
		if (@user.id_guild == -1) then
			@guild = Guild.find_by_id(params[:id]);
			if (@guild.nbmember < @guild.maxmember) then
				@guild.update(nbmember: @guild.nbmember + 1);
			else
				render html: "error_max";
			end
			@user.update({"id_guild": @guild.id});
		else
			render html: "error_alreadyinguild";
		end
		render html: @guild.id;
	end
end