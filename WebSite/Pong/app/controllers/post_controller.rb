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
		if (!User.find_by_nickname(params[:username].downcase))
			User.find_by_id(current_user.id).update({"nickname": params[:username].downcase})
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
		# @Guild = Guild.new
		# @Guild.name = "anatal";
		# @Guild.description = "c'est la guerre";
		# @Guild.id_stats = 3;
		# @Guild.save
		# @Guild2 = Guild.new
		# @Guild2.name = "banal";
		# @Guild2.description = "c'est la guerre mouhahaa";
		# @Guild2.id_stats = 4;
		# @Guild2.save
		# @Guild3 = Guild.new
		# @Guild3.name = "frontal";
		# @Guild3.description = "c'est mouhahaa";
		# @Guild3.id_stats = 5;
		# @Guild3.save
		# @Guild4 = Guild.new
		# @Guild4.name = "choral";
		# @Guild4.description = "chanton ensemble";
		# @Guild4.id_stats = 6;
		# @Guild4.save
		@tab = Guild.order(:name);
		@tab = @tab.as_json(only: [:name, :description, :id_stats])
		render json: @tab
	end
end