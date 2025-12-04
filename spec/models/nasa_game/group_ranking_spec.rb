# frozen_string_literal: true

require "rails_helper"

RSpec.describe NasaGame::GroupRanking, type: :model do
  describe "validations" do
    subject(:ranking) { build(:nasa_game_group_ranking) }

    it "is valid with valid attributes" do
      expect(ranking).to be_valid
    end

    it { is_expected.to validate_presence_of(:item_id) }
    it { is_expected.to validate_presence_of(:rank) }
    it { is_expected.to validate_numericality_of(:rank).only_integer.is_greater_than_or_equal_to(1).is_less_than_or_equal_to(15) }
    it { is_expected.to validate_uniqueness_of(:item_id).scoped_to(:group_id) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:group).class_name("NasaGame::Group") }
  end

  describe "UUID primary key" do
    it "uses UUID as primary key" do
      ranking = create(:nasa_game_group_ranking)
      expect(ranking.id).to be_present
      expect(ranking.id).to match(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i)
    end
  end

  describe "#item" do
    it "returns the corresponding NasaGame::Item" do
      ranking = create(:nasa_game_group_ranking, item_id: 1)
      expect(ranking.item).to be_a(NasaGame::Item)
      expect(ranking.item.id).to eq(1)
    end
  end

  describe "#error_score" do
    it "calculates the absolute difference between rank and correct rank" do
      ranking = build(:nasa_game_group_ranking, item_id: 1, rank: 5)
      # Item 1 has correct_rank of 1
      expect(ranking.error_score).to eq(4)
    end

    it "returns 0 when rank matches correct rank" do
      ranking = build(:nasa_game_group_ranking, item_id: 1, rank: 1)
      expect(ranking.error_score).to eq(0)
    end
  end
end
