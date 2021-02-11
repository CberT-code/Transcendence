class GameController < ApplicationController
	skip_before_action :verify_authenticity_token
	
	def positions

		json_data = JSON.parse(request.body.read)
		uu = json_data['UU'].to_i
		ud = json_data['UD'].to_i
		ou = json_data['OU'].to_i
		od = json_data['OD'].to_i
		pos_u = json_data['pos_u'].to_i
		pos_o = json_data['pos_o'].to_i
		ball_x = json_data['ball_x'].to_i
		ball_y = json_data['bal_y'].to_i
		status = json_data['status'].to_i

		if (uu != 0)
			pos_u += 10
		end
		if (ud != 0)
			pos_u -= 10
		end
		if (ou != 0)
			pos_o += 10
		end
		if (od != 0)
			pos_o -= 10
		end

		render :json => {
		'UU': uu,
		'UD': ud,
		'OU': ou,
		'OD': od,
		'pos_u': pos_u,
		'pos_o': pos_o,
		'ball_x': ball_x,
		'ball_y': ball_y,
		'status': status
	}
	   
	   end
end
