# frozen_string_literal: true

require "rails_helper"

RSpec.describe NasaGame::Participant, type: :model do
  describe "validations" do
    subject(:participant) { build(:nasa_game_participant) }

    it "is valid with valid attributes" do
      expect(participant).to be_valid
    end

    it { is_expected.to validate_presence_of(:display_name) }
    it { is_expected.to validate_uniqueness_of(:session_token) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:session).class_name("NasaGame::Session") }
    it { is_expected.to belong_to(:group).class_name("NasaGame::Group") }
    it { is_expected.to have_many(:individual_rankings).class_name("NasaGame::IndividualRanking").dependent(:destroy) }
  end

  describe "UUID primary key" do
    it "uses UUID as primary key" do
      participant = create(:nasa_game_participant)
      expect(participant.id).to be_present
      expect(participant.id).to match(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i)
    end
  end

  describe "session_token" do
    it "generates a unique session_token before validation if not present" do
      participant = build(:nasa_game_participant, session_token: nil)
      participant.valid?
      expect(participant.session_token).to be_present
    end

    it "does not overwrite existing session_token" do
      existing_token = SecureRandom.urlsafe_base64(32)
      participant = build(:nasa_game_participant, session_token: existing_token)
      participant.valid?
      expect(participant.session_token).to eq(existing_token)
    end
  end

  describe "individual_completed_at" do
    subject(:participant) { create(:nasa_game_participant) }

    it "is nil by default" do
      expect(participant.individual_completed_at).to be_nil
    end

    it "can be set to mark individual work as completed" do
      participant.update!(individual_completed_at: Time.current)
      expect(participant.individual_completed_at).to be_present
    end
  end

  describe "#individual_completed?" do
    subject(:participant) { create(:nasa_game_participant) }

    it "returns false when individual_completed_at is nil" do
      expect(participant).not_to be_individual_completed
    end

    it "returns true when individual_completed_at is set" do
      participant.update!(individual_completed_at: Time.current)
      expect(participant).to be_individual_completed
    end
  end
end
