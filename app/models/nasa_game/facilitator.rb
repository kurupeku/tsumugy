# frozen_string_literal: true

module NasaGame
  class Facilitator < ApplicationRecord
    belongs_to :user,
               class_name: "User",
               inverse_of: :nasa_game_facilitators

    belongs_to :session,
               class_name: "NasaGame::Session",
               inverse_of: :facilitators

    validates :user_id, uniqueness: { scope: :session_id, message: :already_facilitator }
  end
end
