class UsersController < ApplicationController
	before_action do |sign_n_out|
		if !user_signed_in?
			render 'pages/not_authentificate', :status => :unauthorized
		end
		@admin = current_user.role;
		@user = User.find_by_id(params[:id]);
	end

	def index
		@Users = User.where("deleted = ?", FALSE);
	end

	def show
		if (!@user.deleted)
			@user_stat = @user.stat;
			@guild = @user.guild;
			@current = current_user.id == @user.id ? 1 : 0;
			@histories = History.where('host_id = ? or opponent_id = ?', @user.id, @user.id);
		else
			render 'error/403', :status => :unauthorized
		end
	end

	def update
		@current = current_user.id == @user.id ? 1 : 0;
		if (@current == 1 || @admin == 1)
			if (params.has_key?(:checked))
				User.find_by_id(@user.id).update({"available": params[:checked]});
				render html: "success";
			elsif (params.has_key?(:username))
				if (!safestr(params[:username]))
					render html: "special-characters"
				elsif (params[:username] == "")
					render html: "error-incomplete";
				elsif (!User.find_by_nickname(params[:username]))
					@user.update({"nickname": params[:username]});
					render html: "success";
				else
					render html: "errorusername_exist";
				end
			end
		else
			render 'error/403', :status => :unauthorized;
		end
	end

	def destroy
		@current = current_user.id == @user.id ? 1 : 0;
		if (@current == 1 || @admin == 1)
			if (@user.guild_id)
				render html: "error-inguild";
			else
				@user.destroy()
				redirect_to destroy_user_session_path
			end
		else
			render html: "error-forbidden";
		end
	end
end
