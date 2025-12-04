# frozen_string_literal: true

module NasaGame
  class GroupRanking < ApplicationRecord
    belongs_to :group,
               class_name: "NasaGame::Group",
               inverse_of: :group_rankings

    validates :item_id, presence: true, uniqueness: { scope: :group_id }
    validates :rank, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 15 }

    def item
      NasaGame::Item.find(item_id)
    end

    def error_score
      (rank - item.correct_rank).abs
    end
  end
end
