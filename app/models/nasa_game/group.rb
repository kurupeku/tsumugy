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

    def completed?
      completed_at.present?
    end
  end
end
