# frozen_string_literal: true

module NasaGame
  class Session < ApplicationRecord
    SESSION_DURATION = 1.day

    has_many :facilitators,
             class_name: "NasaGame::Facilitator",
             foreign_key: :session_id,
             dependent: :destroy,
             inverse_of: :session

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

    scope :expired, -> { where(expires_at: ...Time.current) }
    scope :active, -> { where(expires_at: Time.current..) }

    before_validation :set_default_expires_at, on: :create

    def expired?
      expires_at < Time.current
    end

    def extend_expiration!
      update!(expires_at: SESSION_DURATION.from_now)
    end

    private

    def set_default_expires_at
      self.expires_at ||= SESSION_DURATION.from_now
    end
  end
end
