# frozen_string_literal: true

module NasaGame
  class GroupRanking < ApplicationRecord
    belongs_to :group,
               class_name: "NasaGame::Group",
               inverse_of: :group_rankings

    validates :item_id, presence: true, uniqueness: { scope: :group_id }
    validates :rank, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 15 }

    # Used to identify who made the change (for ignoring own broadcasts)
    attr_accessor :changed_by_participant_id

    after_commit :broadcast_ranking_changed, on: :update, if: :saved_change_to_rank?

    def item
      NasaGame::Item.find(item_id)
    end

    def error_score
      (rank - item.correct_rank).abs
    end

    private

    def broadcast_ranking_changed
      ActionCable.server.broadcast(
        group.stream_name,
        {
          type: "ranking_changed",
          changed_by: changed_by_participant_id,
          html: render_ranking_list
        }
      )
    end

    def render_ranking_list
      ApplicationController.render(
        partial: "nasa_game/participants/team_ranking_list",
        locals: { group: group.reload, group_rankings: group.group_rankings.order(:rank) }
      )
    end
  end
end
