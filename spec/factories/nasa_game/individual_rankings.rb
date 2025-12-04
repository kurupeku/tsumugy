# frozen_string_literal: true

FactoryBot.define do
  factory :nasa_game_individual_ranking, class: "NasaGame::IndividualRanking" do
    association :participant, factory: :nasa_game_participant
    sequence(:item_id) { |n| ((n - 1) % 15) + 1 }
    sequence(:rank) { |n| ((n - 1) % 15) + 1 }
  end
end
