class PresenceChannel < ApplicationCable::Channel
  def subscribed
    stream_from "presence_#{params[:room]}"
    @redis = Redis.new(url:  ENV['REDIS_URL'],
		port: ENV['REDIS_PORT'],
		db:   ENV['REDIS_DB'])
    @redis.set("player_#{self.current_user.id}", "online")
	puts "\n\nplayer # #{self.current_user.id} just logged to |presence_#{params[:room]}|\n\n"
  end

  def receive(data)

  end

  def unsubscribed
    @redis.set("player_#{self.current_user.id}", "offline") 
	puts "\n\nplayer # #{self.current_user.id} just quit |presence_#{params[:room]}|\n\n"
  end
end
