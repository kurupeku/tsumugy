# frozen_string_literal: true

FactoryBot.define do
  factory :nasa_game_session, class: "NasaGame::Session" do
    phase { :lobby }
  end
end
