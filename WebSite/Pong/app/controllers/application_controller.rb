require 'cgi'

class ApplicationController < ActionController::Base
	before_action :configure_permitted_parameters, if: :devise_controller?
	protect_from_forgery with: :exception

	@warsstatus1 = War.where('status = ?', 1);
	@warsstatus1.each do |war|
		@timetostart = ((war.start.to_i) - DateTime.current.to_i).to_i;
		if (@timetostart < 1)
			if (war.team1.count < war.players)
				while war.team1.count < war.players do
					User.where('guild_id = ?', war.guild1_id).each do |user|
						if (!war.team1.include?user.id)
							war.team1.push(user.id);
						end
					end
				end
			end
			if (war.team2.count < war.players)
				while war.team2.count < war.players do
					User.where('guild_id = ?', war.guild2_id).each do |user|
						if (!war.team2.include?user.id)
							war.team2.push(user.id);
						end
					end
				end
			end
			war.update(status: 2) ;
		end
	end
	@warsstatus2 = War.where('status = ?', 2);
	@warsstatus2.each do |war|
		@timetostart2 = ((war.end.to_i) - DateTime.current.to_i).to_i;
		if (@timetostart2 < 1)
			if (war.points_guild1 > war.points_guild2)
				@guild = Guild.find_by_id(war.guild1_id);
				@guild.update(points: @guild.points + war.points)
			elsif (war.points_guild1 < war.points_guild2)
				@guild = Guild.find_by_id(war.guild2_id);
				@guild.update(points: @guild.points + war.points)
			end
			war.update(status: 3);
		end
	end



	def safestr(string)
		if (string !~ /[!@#$%^&*()_+{}\[\]:;'"\/\\?><.,]/)
			return true;
		else
			return false;
		end
	end
	def safesentence(string)
		if (string !~ /[!@#$%^&*()_+{}\[\]:;'"\/\\?><]/)
			return true;
		else
			return false;
		end
	end

	protected

	def configure_permitted_parameters
		devise_parameter_sanitizer.permit(:sign_in, keys: [:otp_attempt])
	end
end

