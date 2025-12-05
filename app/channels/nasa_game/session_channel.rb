# frozen_string_literal: true

module NasaGame
  class SessionChannel < ApplicationCable::Channel
    def subscribed
      @session = NasaGame::Session.find_by(id: params[:session_id])

      if @session && !@session.expired?
        stream_from stream_name
      else
        reject
      end
    end

    def unsubscribed
      stop_all_streams
    end

    private

    def stream_name
      "nasa_game:session:#{@session.id}"
    end
  end
end
