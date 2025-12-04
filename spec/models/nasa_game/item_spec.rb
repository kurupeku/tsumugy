# frozen_string_literal: true

require "rails_helper"

RSpec.describe NasaGame::Item do
  describe ".all" do
    it "returns all 15 items" do
      expect(described_class.all.count).to eq(15)
    end
  end

  describe ".find" do
    it "returns item by id" do
      item = described_class.find(1)
      expect(item).to be_present
      expect(item.id).to eq(1)
    end
  end

  describe "attributes" do
    subject(:item) { described_class.find(1) }

    it "has correct_rank" do
      expect(item.correct_rank).to eq(1)
    end

    it "has name_ja" do
      expect(item.name_ja).to be_present
    end

    it "has name_en" do
      expect(item.name_en).to be_present
    end

    it "has reasoning_ja" do
      expect(item.reasoning_ja).to be_present
    end

    it "has reasoning_en" do
      expect(item.reasoning_en).to be_present
    end
  end

  describe "correct ranks" do
    it "has unique correct_rank for each item" do
      ranks = described_class.all.map(&:correct_rank)
      expect(ranks.uniq.sort).to eq((1..15).to_a)
    end
  end

  describe ".find_by_correct_rank" do
    it "returns item by correct_rank" do
      item = described_class.find_by(correct_rank: 1)
      expect(item.name_ja).to include("酸素")
    end
  end

  describe "specific items" do
    it "has oxygen tank as rank 1" do
      item = described_class.find_by(correct_rank: 1)
      expect(item.name_ja).to include("酸素")
    end

    it "has water as rank 2" do
      item = described_class.find_by(correct_rank: 2)
      expect(item.name_ja).to include("水")
    end

    it "has matches as rank 15" do
      item = described_class.find_by(correct_rank: 15)
      expect(item.name_ja).to include("マッチ")
    end
  end
end
