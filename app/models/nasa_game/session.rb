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
    after_update_commit :broadcast_phase_change, if: :saved_change_to_phase?

    def expired?
      expires_at < Time.current
    end

    def extend_expiration!
      update!(expires_at: SESSION_DURATION.from_now)
    end

    # Stream name for Action Cable broadcasts
    def stream_name
      "nasa_game:session:#{id}"
    end

    private

    def set_default_expires_at
      self.expires_at ||= SESSION_DURATION.from_now
    end

    def broadcast_phase_change
      ActionCable.server.broadcast(stream_name, { type: "phase_changed", phase: phase })
    end
  end
end
