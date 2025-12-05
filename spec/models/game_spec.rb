# frozen_string_literal: true

require "rails_helper"

RSpec.describe Game do
  describe "data integrity" do
    it "has at least one game" do
      expect(described_class.all).not_to be_empty
    end

    it "has unique ids" do
      ids = described_class.all.map(&:id)
      expect(ids).to eq(ids.uniq)
    end

    it "has unique slugs" do
      slugs = described_class.all.map(&:slug)
      expect(slugs).to eq(slugs.uniq)
    end

    it "has required fields for all games" do
      described_class.all.each do |game|
        expect(game.slug).to be_present, "Game #{game.id} missing slug"
        expect(game.name_ja).to be_present, "Game #{game.id} missing name_ja"
        expect(game.name_en).to be_present, "Game #{game.id} missing name_en"
        expect(game.icon).to be_present, "Game #{game.id} missing icon"
        expect(game.icon_bg_class).to be_present, "Game #{game.id} missing icon_bg_class"
      end
    end
  end

  describe ".available" do
    it "returns only available games" do
      available_games = described_class.available
      expect(available_games).to all(satisfy(&:available?))
    end

    it "includes NASA game" do
      expect(described_class.available.map(&:slug)).to include("nasa_game")
    end
  end

  describe ".coming_soon" do
    it "returns only unavailable games" do
      coming_soon_games = described_class.coming_soon
      expect(coming_soon_games).to all(satisfy { |g| !g.available? })
    end
  end

  describe "NASA game" do
    subject(:nasa_game) { described_class.find_by(slug: "nasa_game") }

    it "exists" do
      expect(nasa_game).to be_present
    end

    it "is available" do
      expect(nasa_game).to be_available
    end

    it "has start_path" do
      expect(nasa_game.start_path).to eq("nasa_game_root_path")
    end

    it "has image" do
      expect(nasa_game).to have_image
    end

    it "has flow steps" do
      expect(nasa_game.flow_steps_ja).not_to be_empty
      expect(nasa_game.flow_steps_en).not_to be_empty
    end
  end

  describe "locale-aware accessors" do
    let(:nasa_game) { described_class.find_by(slug: "nasa_game") }

    context "when locale is ja" do
      before { I18n.locale = :ja }

      after { I18n.locale = I18n.default_locale }

      it "returns Japanese name" do
        expect(nasa_game.name).to eq("NASAゲーム")
      end

      it "returns Japanese subtitle" do
        expect(nasa_game.subtitle).to eq("月面からの脱出")
      end

      it "returns Japanese short_description" do
        expect(nasa_game.short_description).to include("月面からの脱出")
      end

      it "returns Japanese description" do
        expect(nasa_game.description).to include("月面に不時着した宇宙飛行士")
      end

      it "returns Japanese players" do
        expect(nasa_game.players).to eq("4〜8人")
      end

      it "returns Japanese duration" do
        expect(nasa_game.duration).to eq("30〜45分")
      end

      it "returns Japanese flow_steps" do
        expect(nasa_game.flow_steps.first).to include("ファシリテーター")
      end
    end

    context "when locale is en" do
      before { I18n.locale = :en }

      after { I18n.locale = I18n.default_locale }

      it "returns English name" do
        expect(nasa_game.name).to eq("NASA Game")
      end

      it "returns English subtitle" do
        expect(nasa_game.subtitle).to eq("Escape from the Moon")
      end

      it "returns English short_description" do
        expect(nasa_game.short_description).to include("Escape from the Moon")
      end

      it "returns English description" do
        expect(nasa_game.description).to include("crash-landed on the moon")
      end

      it "returns English players" do
        expect(nasa_game.players).to eq("4-8 players")
      end

      it "returns English duration" do
        expect(nasa_game.duration).to eq("30-45 min")
      end

      it "returns English flow_steps" do
        expect(nasa_game.flow_steps.first).to include("Facilitator")
      end
    end
  end

  describe "#available?" do
    it "returns true for available games" do
      nasa_game = described_class.find_by(slug: "nasa_game")
      expect(nasa_game.available?).to be true
    end

    it "returns false for coming soon games" do
      coming_soon = described_class.find_by(slug: "coming_soon_1")
      expect(coming_soon.available?).to be false
    end
  end

  describe "#has_image?" do
    it "returns true when image_path is present" do
      nasa_game = described_class.find_by(slug: "nasa_game")
      expect(nasa_game.has_image?).to be true
    end

    it "returns false when image_path is nil" do
      coming_soon = described_class.find_by(slug: "coming_soon_1")
      expect(coming_soon.has_image?).to be false
    end
  end
end
