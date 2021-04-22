class GuildsController < ApplicationController
	before_action do |sign_n_out|
		if !user_signed_in?
			render 'pages/not_authentificate', :status => :unauthorized
		end
		@admin = current_user.role == 1 ? 1 : 0;
	end

	def index
		@guilds = Guild.where("deleted = ?", false);
	end

	def new
		if (current_user.guild_id) then
			render 'error/403', :status => :unauthorized
		end
	end

	def create
		if (current_user.guild_id) then
			render 'error/403', :status => :unauthorized
		end
		if (params[:guildname] == "" || !safestr(params[:guildname]))
			render html: "error-1";
		elsif (params[:anagramme].length > 5 || Guild.find_by_anagramme(params[:anagramme]))
			render html: "error-6";
		elsif (!safestr(params[:anagramme]))
			render html: "error-7";
		elsif (params[:guildstory] == "" || !safesentence(params[:guildstory]))
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
			@guild.update({name: params[:guildname], anagramme: params[:guildname].first(5), description: params[:guildstory], id_stats: @stat.id, maxmember: params[:maxmember], id_admin: current_user.id, deleted: false});
			@guild.users.size = 1;
			@guild.save;
			current_user.update({"guild_id": @guild.id});
			render html: @guild.id;
		end
	end

	def show
		@guild = Guild.find_by_id(params[:id]);
		@officer = (@guild.officers.include?current_user.id) ? 1 : 0;
		if (@guild.deleted == true)
			render 'error/403', :status => :unauthorized;
		end
		@user = current_user;
		@my_guild = @guild.id == current_user.guild_id ? 1 : 0;
		@wars_histories = History.where('host_id = ? or opponent_id = ?', @guild.id, @guild.id);
		@list_users = @guild.users.all;
		@ban_users = @guild.banned;
		@admin_guild = current_user.id == @guild.id_admin ? 1 : 0;
	end

	def update
		
		@new_admin = User.find_by_id(params[:id_admin]);
		@guild = Guild.find_by_id(@new_admin.guild_id);
		if ((current_user.guild_id == @guild.id && @guild.id_admin == current_user.id  ) || @admin == 1)
			@guild.update({'id_admin': @new_admin.id});
			render html: @guild.id;
		else
			render html: "error-badguild";
		end
	end

	def destroy
		@usertodelete = User.find_by_id(params[:id])
		@guild = @usertodelete.guild
		@admin = (current_user.role == 1 || @guild.id_admin == current_user.id) ? 1 : 0
		@officer = (@guild.officers.include?current_user.id) ? 1 : 0
		if @guild.id_admin == @usertodelete.id && @guild.users.size != 1
			render json: {status: "error", info: "Trying to delete admin"}
		elsif @usertodelete.id == current_user.id && @guild.users.size != 1
			@guild.officers.delete(@usertodelete.id)
			@usertodelete.update({"guild_id": nil})
			render json: {status: '1', info: "Self-kick from guild"}
		elsif @usertodelete.guild_id && (@admin == 1 || (@officer == 1 && @usertodelete.id != @guild.id_admin))
			if @guild.users.size == 1
				@guild.update(id_admin: 0, deleted: true)
				@guild.officers.delete(@usertodelete.id)
				render json: {status: '1', info: "removed only member of the guild"}
			else
				@guild.officers.delete(@usertodelete.id)
				render json: {status: '2', info: "removed a member of the guild"}
			end
			@usertodelete.update({"guild_id": nil})
		else
			render json: {status: '1', info: "did nothing"}
		end
		@guild.save
		@usertodelete.save!
	end

	def ban
		@usertoban = User.find_by_id(params[:id]);
		@guild = @usertoban.guild;
		@admin = (current_user.role == 1 || @guild.id_admin == current_user.id) ? 1 : 0;
		if (@usertoban.guild_id && @admin == 1) then
			if (@guild.id_admin == @usertoban.id && @guild.users.size != 1)
				render html: "error-admin";
			else
				if (@guild.users.size == 1)
					render html: "error-one";
				elsif (@usertoban.id == current_user.id)
					render html: "error-yourself";
				else
					@guild.update(nbmember: @guild.users.size - 1);
					@usertoban.update({"guild_id": nil});
					if (@guild.banned.count == 0)
						@guild.update({banned: [@usertoban.id]});
					else
						@guild.banned.push(@usertoban.id);
					end
				end
				@guild.save();
			end
		else
			render html: "error-forbidden";
		end
	end

	def unban
		@usertounban = User.find_by_id(params[:id]);
		@guild = Guild.find_by_id(params[:idguild]);
		@admin = (current_user.role == 1 || @guild.id_admin == current_user.id) ? 1 : 0;
		if (@admin == 1)
			@guild.banned.delete(@usertounban.id);
		end
		@guild.save();
	end

	def join
		@user = current_user;
		if (!@user.guild_id) then
			@guild = Guild.find_by_id(params[:id]);
			if (@guild.banned.include? @user.id)
				render html: "error_banned";
			elsif (@guild.users.size < @guild.maxmember)
				@guild.update(nbmember: @guild.users.size + 1);
				@user.update({"guild_id": @guild.id});
				render html: @guild.id;
			else
				render html: "error_max";
			end
		else
			render html: "error_alreadyinguild";
		end
	end

	def search
		@list_guild = Guild.where("LOWER(name) LIKE LOWER(?) AND DELETED IS FALSE","%" + params[:search] + "%");
		@ret = Array.new
		@list_guild.each do |guild|
			@ret.push(["id" => guild.id, "name" => CGI.escapeHTML(guild.name), "nbmember" => guild.nbmember])
		end
		render json: @ret
	end

	def officer
		usertochange = User.find_by_id(params[:id]);
		guild = Guild.find_by_id(params[:idguild]);
		admin = (current_user.role == 1 || guild.id_admin == current_user.id) ? 1 : 0;
		officer = (guild.officers.include?current_user.id) ? 1 : 0;
		if (admin == 1 || officer == 1)
			role = params[:select] == "officer" ? 1 : 0;
			if (role == 1 && !(guild.officers.include?usertochange.id))
				guild.officers.push(usertochange.id)
				render json: {status: "change ok", user: usertochange.nickame, role: "Officer"}
			elsif (role == 0 && (guild.officers.include?usertochange.id))
				guild.officers.delete(usertochange.id)
				render json: {status: "change ok", user: usertochange.nickname, role: "User"}
			else
				render json: {status: "no change", user: usertochange.nickname, role: params[:select] == "officer" ? "Officer" : "User"}
			end
			guild.save
		else
			render json: {status: "forbidden", user: usertochange.nickname, role: params[:select] == "officer" ? "Officer" : "User"}
		end
	end

	def anagramme
		@anagramme = params[:anagramme]
		if (@anagramme.length > 5)
			render html: "toolong"
		elsif Guild.find_by_anagramme(@anagramme)
			render html: "used"
		end
	end
end