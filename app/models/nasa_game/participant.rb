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
    validates :user_id, uniqueness: { scope: :session_id, message: "このセッションには既に参加しています" }

    def individual_completed?
      individual_completed_at.present?
    end
  end
end
