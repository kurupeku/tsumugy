# frozen_string_literal: true

FactoryBot.define do
  factory :nasa_game_group, class: "NasaGame::Group" do
    session factory: %i[nasa_game_session]
    sequence(:name) { |n| "Group #{('A'.ord + n - 1).chr}" }
    sequence(:position) { |n| n - 1 }
  end
end
