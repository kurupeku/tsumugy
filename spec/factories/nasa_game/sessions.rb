# frozen_string_literal: true

FactoryBot.define do
  factory :nasa_game_session, class: "NasaGame::Session" do
    phase { :lobby }
    expires_at { 1.day.from_now }
  end
end
