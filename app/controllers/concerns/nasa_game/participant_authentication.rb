# frozen_string_literal: true

module NasaGame
  module ParticipantAuthentication
    extend ActiveSupport::Concern

    include UserAuthentication

    included do
      helper_method :current_participant
    end

    private

    def current_participant
      return @current_participant if defined?(@current_participant)

      @current_participant = find_participant_for_current_user
    end

    def find_participant_for_current_user
      return nil unless current_user

      # Find participant based on context
      if defined?(@group) && @group
        # When group is set (joining or group-related pages)
        current_user.nasa_game_participants.find_by(group: @group)
      elsif defined?(@session) && @session
        # When session is set (session-related pages)
        current_user.nasa_game_participants.find_by(session: @session)
      elsif params[:participant_id] || params[:id]
        # When viewing/updating specific participant
        participant_id = params[:participant_id] || params[:id]
        current_user.nasa_game_participants.find_by(id: participant_id)
      end
    end

    def authenticate_participant!
      return if current_participant

      redirect_to nasa_game_root_path, alert: "参加登録が必要です"
    end
  end
end
