class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
	def marvin
	@user = User.from_omniauth(request.env["omniauth.auth"])
	if @user.persisted? && @user.banned == false
		if @user.otp_required_for_login
			@user.locked = true;
			@user.save!
		end
		sign_in_and_redirect @user, :event => :authentication
		set_flash_message(:notice, :success, :kind => "42") if is_navigational_format?
	elsif @user.banned == true
		redirect_to "/pages/ban"
	else
		session["devise.marvin_data"] = request.env["omniauth.auth"]
		redirect_to new_user_registration_url, :method => :delete
	  end
	end

end