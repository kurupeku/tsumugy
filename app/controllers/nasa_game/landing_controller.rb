# frozen_string_literal: true

module NasaGame
  class LandingController < BaseController
    include UserAuthentication

    def index
      cleanup_expired_sessions

      # Priority 1: Facilitator
      facilitator = current_user.nasa_game_facilitators.joins(:session).merge(Session.active).first
      if facilitator
        redirect_to nasa_game_session_path(facilitator.session)
        return
      end

      # Priority 2: Participant
      participant = current_user.nasa_game_participants.joins(:session).merge(Session.active).first
      if participant
        redirect_to nasa_game_participant_path(participant)
        return
      end

      # Default: Create new session
      redirect_to new_nasa_game_session_path
    end

    private

    def cleanup_expired_sessions
      # Delete expired sessions where current user is facilitator
      expired_facilitator_sessions = current_user.nasa_game_facilitators
                                                 .joins(:session)
                                                 .merge(Session.expired)
                                                 .includes(:session)

      expired_facilitator_sessions.each do |facilitator|
        facilitator.session.destroy
      end

      # Delete expired sessions where current user is participant (cascade delete)
      expired_participant_sessions = current_user.nasa_game_participants
                                                 .joins(:session)
                                                 .merge(Session.expired)
                                                 .includes(:session)

      expired_participant_sessions.each do |participant|
        participant.session.destroy
      end
    end
  end
end
