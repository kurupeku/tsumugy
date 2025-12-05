# frozen_string_literal: true

module NasaGame
  class Group < ApplicationRecord
    belongs_to :session,
               class_name: "NasaGame::Session",
               inverse_of: :groups

    has_many :participants,
             class_name: "NasaGame::Participant",
             foreign_key: :group_id,
             dependent: :destroy,
             inverse_of: :group

    has_many :group_rankings,
             class_name: "NasaGame::GroupRanking",
             foreign_key: :group_id,
             dependent: :destroy,
             inverse_of: :group

    validates :name, presence: true
    validates :position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

    after_update_commit :broadcast_team_completed, if: :saved_change_to_completed_at?

    def completed?
      completed_at.present?
    end

    def stream_name
      "nasa_game:group:#{id}"
    end

    private

    def broadcast_team_completed
      # Notify facilitator dashboard
      ActionCable.server.broadcast(
        session.stream_name,
        {
          type: "team_completed",
          group_id: id,
          html: render_group_card,
          stats_html: render_stats
        }
      )

      # Notify group members (for Phase 4)
      ActionCable.server.broadcast(
        stream_name,
        { type: "team_completed" }
      )
    end

    def render_group_card
      ApplicationController.render(
        partial: "nasa_game/sessions/group_card",
        locals: { group: self, session: session }
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
