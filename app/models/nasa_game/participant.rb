# frozen_string_literal: true

module NasaGame
  class Participant < ApplicationRecord
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
    validates :session_token, presence: true, uniqueness: true

    before_validation :generate_session_token, on: :create

    def individual_completed?
      individual_completed_at.present?
    end

    private

    def generate_session_token
      self.session_token ||= SecureRandom.urlsafe_base64(32)
    end
  end
end
