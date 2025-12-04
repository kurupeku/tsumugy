# frozen_string_literal: true

FactoryBot.define do
  factory :nasa_game_group_ranking, class: "NasaGame::GroupRanking" do
    group factory: %i[nasa_game_group]
    sequence(:item_id) { |n| ((n - 1) % 15) + 1 }
    sequence(:rank) { |n| ((n - 1) % 15) + 1 }
  end
end
