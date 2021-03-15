class PongChannel < ApplicationCable::Channel
  def subscribed
    stream_from "pong_#{params[:room]}"
  end

  def receive(data)
    @game = History.find(params[:room])
	@game.statut = data.player.to_i
	@game.save
  end

  def unsubscribed
    @game = History.find(params[:room])
    @game.statut = 3
	@game.save!
  end
end
