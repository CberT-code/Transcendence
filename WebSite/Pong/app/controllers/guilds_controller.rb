class GuildsController < ApplicationController
	before_action do |sign_n_out|
		if !user_signed_in?
			render 'pages/not_authentificate', :status => :unauthorized
		end
		@admin = current_user.role;
	end

	def index
		@guilds = Guild.where("deleted = ?", FALSE);
	end

	def new
		if (current_user.id_guild != -1) then
			render 'error/403', :status => :unauthorized
		end
	end
	
	def create
		if (current_user.id_guild != -1) then
			render 'error/403', :status => :unauthorized
		end
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
		elsif (params[:anagramme].length > 5 || Guild.find_by_anagramme(params[:anagramme]))
			render html: "error-6";
		else
			@guild = Guild.new;
			@stat = Stat.new;
			@stat.save;
			@guild.update({name: params[:guildname], anagramme: params[:guildname].first(5), description: params[:guildstory], id_stats: @stat.id, maxmember: params[:maxmember], id_admin: current_user.id, deleted: false});
			@guild.nbmember = 1;
			@guild.save;
			User.find_by_id(current_user.id).update({"id_guild": @guild.id});
			render html: @guild.id;
		end
	end

	def show
		@guild = Guild.find_by_id(params[:id]);
		@officer = (@guild.officers.include?current_user.id) ? 1 : 0;
		if (@guild.deleted == true)
			render 'error/403', :status => :unauthorized;
		end
		@user = User.find_by_id(current_user.id);
		@my_guild = @guild.id == current_user.id_guild ? 1 : 0;
		@wars_histories = History.where('target_1 = ? or target_2 = ?', @guild.id, @guild.id);
		@list_users = User.where('id_guild = ?', @guild.id);
		@ban_users = @guild.banned;
		@admin_guild = current_user.id == @guild.id_admin ? 1 : 0;
	end

	def update
		
		@new_admin = User.find_by_id(params[:id_admin]);
		@guild = Guild.find_by_id(@new_admin.id_guild);
		if ((@current_user.id_guild == @guild.id && @guild.id_admin == current_user.id  ) || @admin == 1)
			@guild.update({'id_admin': @new_admin.id});
			render html: @guild.id;
		else
			render html: "error-badguild";
		end
	end

	# destroy need a solution to kill user if it's the user or the super admin
	def destroy
		@usertodelete = User.find_by_id(params[:id]);
		@guild = Guild.find_by_id(@usertodelete.id_guild);
		@admin = (current_user.role == 1 || @guild.id_admin == current_user.id) ? 1 : 0;
		@officer = (@guild.officers.include?current_user.id) ? 1 : 0;
		if (@usertodelete.id_guild != -1 && (@admin == 1 || (@officer == 1 && @usertodelete != @guild.id_admin))) then
			if (@guild.id_admin == @usertodelete.id && @guild.nbmember != 1)
				render html: "error-admin";
			else
				if (@guild.nbmember == 1 ) then
					@guild.update(nbmember: 0, id_admin: 0, deleted: true);
					@guild.officers.delete(@usertodelete.id);
				else
					@guild.update(nbmember: @guild.nbmember - 1);
					@guild.officers.delete(@usertodelete.id);
				end
				@usertodelete.update({"id_guild": '-1'});
				render html: 2;
			end
		elsif (@usertodelete.id == current_user.id)
			@guild.update(nbmember: @guild.nbmember - 1);
			@guild.officers.delete(@usertodelete.id);
			@usertodelete.update({"id_guild": '-1'});
			render html: 1;
		else
			render html: 1;
		end
		@guild.save()
	end

	def ban
		@usertoban = User.find_by_id(params[:id]);
		@guild = Guild.find_by_id(@usertoban.id_guild);
		@admin = (current_user.role == 1 || @guild.id_admin == current_user.id) ? 1 : 0;
		if (@usertoban.id_guild != -1 && @admin == 1) then
			if (@guild.id_admin == @usertoban.id && @guild.nbmember != 1)
				render html: "error-admin";
			else
				if (@guild.nbmember == 1)
					render html: "error-one";
				elsif (@usertoban.id == current_user.id)
					render html: "error-yourself";
				else
					@guild.update(nbmember: @guild.nbmember - 1);
					@usertoban.update({"id_guild": '-1'});
					if (@guild.banned.count == 0)
						@guild.update({banned: [@usertoban.id]});
					else
						@guild.banned.push(@usertoban.id);
					end
				end
				# @guild.delete({banned: [@usertoban.id]});
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
		@user = User.find_by_id(current_user.id);
		if (@user.id_guild == -1) then
			@guild = Guild.find_by_id(params[:id]);
			if (@guild.banned.include? @user.id)
				render html: "error_banned";
			elsif (@guild.nbmember < @guild.maxmember)
				@guild.update(nbmember: @guild.nbmember + 1);
				@user.update({"id_guild": @guild.id});
				render html: @guild.id;
			else
				render html: "error_max";
			end
		else
			render html: "error_alreadyinguild";
		end
	end

	def search
		@list_guild = Guild.where("LOWER(name) LIKE LOWER(?)", params[:search] + "%");
		@ret = Array.new
		@list_guild.each do |guild|
			if (guild.id != current_user.id_guild)
				@ret.push(["id" => guild.id, "name" => guild.name, "nbmember" => guild.nbmember])
			end
		end
		render json: @ret
	end

	def officer
		@usertochange = User.find_by_id(params[:id]);
		@guild = Guild.find_by_id(params[:idguild]);
		@admin = (current_user.role == 1 || @guild.id_admin == current_user.id) ? 1 : 0;
		@officer = (@guild.officers.include?current_user.id) ? 1 : 0;
		if (@admin == 1 || @officer == 1)
			@role = params[:select] == "officer" ? 1 : 0;
			if (@role == 1 && !(@guild.officers.include?@usertochange.id))
				@guild.officers.push(@usertochange.id)
				render html: "changed ok"
			elsif (@role == 0 && (@guild.officers.include?@usertochange.id))
				@guild.officers.delete(@usertochange.id)
				render html: "changed ok"
			else
				render html: "no change"
			end
			@guild.save()
		else
			render html: "forbidden"
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