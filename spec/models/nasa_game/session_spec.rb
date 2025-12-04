# frozen_string_literal: true

require "rails_helper"

RSpec.describe NasaGame::Session, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      session = described_class.new(phase: :lobby)
      expect(session).to be_valid
    end

    it "is valid without phase (defaults to lobby)" do
      session = described_class.new
      expect(session).to be_valid
      expect(session.phase).to eq("lobby")
    end
  end

  describe "phase enum" do
    subject(:session) { described_class.new }

    it "defaults to lobby" do
      expect(session).to be_lobby
    end

    it "can be set to individual" do
      session.phase = :individual
      expect(session).to be_individual
    end

    it "can be set to team" do
      session.phase = :team
      expect(session).to be_team
    end

    it "can be set to result" do
      session.phase = :result
      expect(session).to be_result
    end

    it "has correct enum values" do
      expect(described_class.phases).to eq({
        "lobby" => 0,
        "individual" => 1,
        "team" => 2,
        "result" => 3
      })
    end
  end

  describe "UUID primary key" do
    it "uses UUID as primary key" do
      session = described_class.create!
      expect(session.id).to be_present
      expect(session.id).to match(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i)
    end
  end

  describe "associations" do
    it { is_expected.to have_many(:groups).class_name("NasaGame::Group").dependent(:destroy) }
    it { is_expected.to have_many(:participants).class_name("NasaGame::Participant").dependent(:destroy) }
  end

  describe "phase transitions" do
    subject(:session) { described_class.create! }

    it "starts in lobby phase" do
      expect(session).to be_lobby
    end

    it "can transition from lobby to individual" do
      session.individual!
      expect(session).to be_individual
    end

    it "can transition from individual to team" do
      session.individual!
      session.team!
      expect(session).to be_team
    end

    it "can transition from team to result" do
      session.individual!
      session.team!
      session.result!
      expect(session).to be_result
    end
  end
end
