class GameController < ApplicationController
	skip_before_action :verify_authenticity_token

	def positions
		pos_u = 0
		pos_o = 0

		# json_data = params.parse
		# uu = json_data['UU'].to_i
		# ud = json_data['UD'].to_i
		# ou = json_data['OU'].to_i
		# od = json_data['OD'].to_i
		# pos_u = json_data['pos_u'].to_i
		# pos_o = json_data['pos_o'].to_i
		# ball_x = json_data['ball_x'].to_i
		# ball_y = json_data['bal_y'].to_i
		# status = json_data['status'].to_i

		if (params['UD'].to_i != 0)
			pos_u += 10
		end
		# if (params['UU'] != 0)
		# 	pos_u -= 10
		# end
		# if (params['OD'] != 0)
		# 	pos_o += 10
		# end
		# if (params['OU'] != 0)
		# 	pos_o -= 10
		# end

		# render :json => {
		# 	'UU': uu,
		# 	'UD': ud,
		# 	'OU': ou,
		# 	'OD': od,
		# 	'pos_u': pos_u,
		# 	'pos_o': pos_o,
		# 	'ball_x': ball_x,
		# 	'ball_y': ball_y,
		# 	'status': status
		# }
		render :json => { 'User': pos_u, 'Oppo': pos_o }
	   
	   end
end
