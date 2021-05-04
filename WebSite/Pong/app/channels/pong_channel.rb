class PongChannel < ApplicationCable::Channel

  def subscribed
    stream_from "pong_#{params[:room]}"
    @redis = Redis.new(url:  ENV['REDIS_URL'],
		port: ENV['REDIS_PORT'],
		db:   ENV['REDIS_DB'])
    @redis.set("player_#{self.current_user.id}", "static")
  end

  def receive(data)
	if (@redis.get("game_#{data['room']}") == "Looking For Opponent" &&
		data['status'] == "gone")
		@redis.set("game_#{data['room']}", "quit")
		game = Histories.find_by_id(data['room'])
		game.statut = -1
		game.save
	else
		@redis.set("player_#{data['player']}", "#{data['move']}")
	end
  end

  def unsubscribed
    @redis.del("player_#{self.current_user.id}") 
  end
end
