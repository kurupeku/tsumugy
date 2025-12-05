# frozen_string_literal: true

module NasaGame
  class GroupChannel < ApplicationCable::Channel
    def subscribed
      @group = NasaGame::Group.find_by(id: params[:group_id])

      if @group && !@group.session.expired?
        stream_from @group.stream_name
      else
        reject
      end
    end

    def unsubscribed
      stop_all_streams
    end
  end
end
