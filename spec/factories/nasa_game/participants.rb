# frozen_string_literal: true

FactoryBot.define do
  factory :nasa_game_participant, class: "NasaGame::Participant" do
    association :session, factory: :nasa_game_session
    association :group, factory: :nasa_game_group
    sequence(:display_name) { |n| "Player #{n}" }
    session_token { SecureRandom.urlsafe_base64(32) }
  end
end
