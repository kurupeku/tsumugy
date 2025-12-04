# frozen_string_literal: true

class User < ApplicationRecord
  # Default session duration
  SESSION_DURATION = 1.day

  has_many :nasa_game_participants,
           class_name: "NasaGame::Participant",
           foreign_key: :user_id,
           dependent: :destroy,
           inverse_of: :user

  has_many :nasa_game_facilitators,
           class_name: "NasaGame::Facilitator",
           foreign_key: :user_id,
           dependent: :destroy,
           inverse_of: :user

  validates :session_token, presence: true, uniqueness: true

  before_validation :generate_session_token, on: :create
  before_validation :set_default_expires_at, on: :create

  scope :expired, -> { where(expires_at: ...Time.current) }
  scope :active, -> { where(expires_at: Time.current..) }

  # Extends the expiration time by SESSION_DURATION from now
  def extend_expiration!
    update!(expires_at: SESSION_DURATION.from_now)
  end

  def expired?
    expires_at < Time.current
  end

  private

  def generate_session_token
    self.session_token ||= SecureRandom.urlsafe_base64(32)
  end

  def set_default_expires_at
    self.expires_at ||= SESSION_DURATION.from_now
  end
end
