# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    session_token { SecureRandom.urlsafe_base64(32) }
    expires_at { 1.day.from_now }
  end
end
