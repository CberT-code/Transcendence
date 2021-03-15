class PongChannel < ApplicationCable::Channel
  def subscribed
    stream_from "pong_#{params[:room]}"
  end

  def unsubscribed
    game = History.find(params[:room])
    game.statut = 3
    game.save
  end
end
