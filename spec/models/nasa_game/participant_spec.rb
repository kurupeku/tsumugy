# frozen_string_literal: true

require "rails_helper"

RSpec.describe NasaGame::Participant, type: :model do
  describe "validations" do
    subject(:participant) { build(:nasa_game_participant) }

    it "is valid with valid attributes" do
      expect(participant).to be_valid
    end

    it { is_expected.to validate_presence_of(:display_name) }

    describe "user_id uniqueness scoped to session_id" do
      let(:user) { create(:user) }
      let(:session) { create(:nasa_game_session) }
      let(:group) { create(:nasa_game_group, session:) }

      before do
        create(:nasa_game_participant, user:, session:, group:)
      end

      it "does not allow same user to join same session twice" do
        another_group = create(:nasa_game_group, session:)
        duplicate = build(:nasa_game_participant, user:, session:, group: another_group)
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:user_id]).to include("このセッションには既に参加しています")
      end

      it "allows same user to join different sessions" do
        another_session = create(:nasa_game_session)
        another_group = create(:nasa_game_group, session: another_session)
        new_participant = build(:nasa_game_participant, user:, session: another_session, group: another_group)
        expect(new_participant).to be_valid
      end
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:user).class_name("User") }
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
