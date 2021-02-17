class GameController < ApplicationController
	skip_before_action :verify_authenticity_token

	def positions
		@me = current_user

		if (params['UD'].to_i != 0)
			@me.position += 10
		end
		if (params['UU'].to_i != 0)
			@me.position -= 10
		end
		@me.position.save # maybe ?
		# if (params['OD'].to_i != 0)
		# 	pos_o += 10
		# end
		# if (params['OU'].to_i != 0)
		# 	pos_o -= 10
		# end

		render :json => { 'User': @me.position, 'Oppo': 0 }
	   
	   end
end
