class PresenceChannel < ApplicationCable::Channel
  def subscribed
    stream_from "presence_#{params[:room]}"
    @redis = Redis.new(url:  ENV['REDIS_URL'],
		port: ENV['REDIS_PORT'],
		db:   ENV['REDIS_DB'])
    @redis.set("player_#{self.current_user.id}", "online")
	self.current_user.notifyFriends("online")
  end

  def receive(data)

  end

  def unsubscribed
    @redis.set("player_#{self.current_user.id}", "offline") 
	self.current_user.notifyFriends("offline")
end
end
