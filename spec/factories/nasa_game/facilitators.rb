# frozen_string_literal: true

FactoryBot.define do
  factory :nasa_game_facilitator, class: "NasaGame::Facilitator" do
    user factory: %i[user]
    session factory: %i[nasa_game_session]
  end
end
