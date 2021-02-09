class GameController < ApplicationController
	protect_from_forgery with: :null_session
	
	def positions
		bod = request.body

		json_data = JSON.parse(request.body.read)
		keys = json_data['keys']
		players = json_data['pos']
		ball = json_data['ball']
		status = json_data['status']

		# if keys[0]
		# 	players[0] += 10
		# end
		# if keys[1]
		# 	players[0] -= 10
		# end

		render :json => {:keys => keys, :position => players, :ball => ball, :status => status, :type => keys.is_a?(String)}
	   
	   end
end
