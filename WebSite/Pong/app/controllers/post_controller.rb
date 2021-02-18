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
		# @History = History.new
		# @History.target_1 = 1;
		# @History.target_2 = 3;
		# @History.score_target_1 = 14;
		# @History.score_target_2 = 0;
		# @History.save
		# @History2 = History.new
		# @History2.target_1 = 2;
		# @History2.target_2 = 1;
		# @History2.score_target_1 = 16;
		# @History2.score_target_2 = 4;
		# @History2.save
		@tab = History.where('(target_1 = ? or target_2 = ?) and target_type = ?', current_user.id, current_user.id, 1);
		# @tab = @tab.select(:target_1, :target_2, :score_target_1, :score_target_2);
		@tab = @tab.as_json(only: [:target_1, :target_2, :score_target_1, :score_target_2])
		@tab.each do |ta|
			@name = User.find_by_id(ta["target_1"]);
			@name2 = User.find_by_id(ta["target_2"]);
			ta["target_1"] = @name.nickname;
			ta["target_2"] = @name2.nickname;
		end
		render json: @tab
	end
end