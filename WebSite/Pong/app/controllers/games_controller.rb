class GameController < ApplicationController
	skip_before_action :verify_authenticity_token

	def home
		@me  = current_user
	end

	def positions
		raise
		@me = current_user

		if (params['UD'].to_i != 0)
			@me.position -= 10
			if @me.position < 0
				@me.position = 0
			end
		end
		if (params['UU'].to_i != 0)
			@me.position += 10
			if @me.position > params['height'].to_i
				@me.position = params['height'].to_i
			end
		end
		@me.save! # maybe ?
		# if (params['OD'].to_i != 0)
		# 	pos_o += 10
		# end
		# if (params['OU'].to_i != 0)
		# 	pos_o -= 10
		# end
		left_url = 'url("' + @me.picture_url + '")'
		right_url = 'url("' + @me.picture_url + '")'

		render :json => { 'User': @me.position, 'Oppo': 0, 'Left_pp': left_url, 'right_pp': right_url}
	   
	   end

	def setup
		@me = current_user
		if (find_game() == 'NO')
		render :json => { 'Ready': "No", 'Hotel?': "Trivago"}
	end

	def new
		
	end
end
