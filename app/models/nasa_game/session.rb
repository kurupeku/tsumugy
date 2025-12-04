# frozen_string_literal: true

module NasaGame
  class Session < ApplicationRecord
    has_many :groups,
             class_name: "NasaGame::Group",
             foreign_key: :session_id,
             dependent: :destroy,
             inverse_of: :session

    has_many :participants,
             class_name: "NasaGame::Participant",
             foreign_key: :session_id,
             dependent: :destroy,
             inverse_of: :session

    enum :phase, { lobby: 0, individual: 1, team: 2, result: 3 }
  end
end
