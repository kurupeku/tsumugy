# frozen_string_literal: true

module NasaGame
  class Participant < ApplicationRecord
    belongs_to :user,
               class_name: "User",
               inverse_of: :nasa_game_participants

    belongs_to :session,
               class_name: "NasaGame::Session",
               inverse_of: :participants

    belongs_to :group,
               class_name: "NasaGame::Group",
               inverse_of: :participants

    has_many :individual_rankings,
             class_name: "NasaGame::IndividualRanking",
             foreign_key: :participant_id,
             dependent: :destroy,
             inverse_of: :participant

    validates :display_name, presence: true
    validates :user_id, uniqueness: { scope: :session_id, message: :already_joined_session }

    after_create_commit :broadcast_participant_joined
    after_update_commit :broadcast_individual_completed, if: :saved_change_to_individual_completed_at?

    def individual_completed?
      individual_completed_at.present?
    end

    private

    def broadcast_participant_joined
      broadcast_dashboard_update("participant_joined")
    end

    def broadcast_individual_completed
      broadcast_dashboard_update("individual_completed")
    end

    def broadcast_dashboard_update(type)
      ActionCable.server.broadcast(
        session.stream_name,
        {
          type: type,
          group_id: group_id,
          html: render_group_card,
          stats_html: render_stats
        }
      )
    end

    def render_group_card
      ApplicationController.render(
        partial: "nasa_game/sessions/group_card",
        locals: { group: group, session: session }
      )
    end

    def render_stats
      ApplicationController.render(
        partial: "nasa_game/sessions/stats",
        locals: { session: session.reload, groups: session.groups }
      )
    end
  end
end
