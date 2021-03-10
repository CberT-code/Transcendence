class UsersController < ApplicationController
	before_action do |sign_n_out|
		if !user_signed_in?
			render 'pages/not_authentificate', :status => :unauthorized
		end
	end

	def index
		@Users = User.all.order('nickname')
	end

	def show
		@user = !params[:id] ? User.find_by_id(current_user.id) : @user = User.find_by_id(params[:id]);
		@super_admin = current_user.role;
		@user_stat = Stat.find_by_id(@user.id_stats);
		@guild = Guild.find_by_id(@user.id_guild);
		@current = current_user.id == @user.id ? 1 : 0;
		@histories = History.where('(target_1 = ? or target_2 = ?) and target_type = ?', @user.id, @user.id, 1);
	end

	def update
		@user = !params[:id] ? User.find_by_id(current_user.id) : @user = User.find_by_id(params[:id]);
		@super_admin = current_user.role;
		@current = current_user.id == @user.id ? 1 : 0;
		if (@current == 1 || @super_admin == 1)
			if (!User.find_by_nickname(params[:username]))
				User.find_by_id(@user.id).update({"nickname": params[:username]})
				render html: "1";
			else
				render html: "2";
			end
		else
			render html: "error-forbidden";
		end
	end

	def destroy
		@user = !params[:id] ? User.find_by_id(current_user.id) : @user = User.find_by_id(params[:id]);
		@super_admin = current_user.role;
		@current = current_user.id == @user.id ? 1 : 0;
		if (@current == 1 || @super_admin == 1)
			if (@user.id_guild != -1)
				render html: "error-inguild"
			else
				Stat.find_by_id(@user.id_stats).destroy;
				User.find_by_id(@user.id).destroy;
				destroy_user_session_path
				render html: "1"
			end
		else
			render html: "error-forbidden";
		end
	end
end
