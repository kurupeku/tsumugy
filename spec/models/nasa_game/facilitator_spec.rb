# frozen_string_literal: true

require "rails_helper"

RSpec.describe NasaGame::Facilitator, type: :model do
  describe "validations" do
    subject(:facilitator) { build(:nasa_game_facilitator) }

    it "is valid with valid attributes" do
      expect(facilitator).to be_valid
    end

    describe "user_id uniqueness scoped to session_id" do
      let(:user) { create(:user) }
      let(:session) { create(:nasa_game_session) }

      before do
        create(:nasa_game_facilitator, user:, session:)
      end

      it "does not allow same user to facilitate same session twice" do
        duplicate = build(:nasa_game_facilitator, user:, session:)
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:user_id]).to include("このセッションでは既にファシリテーターです")
      end

      it "allows same user to facilitate different sessions" do
        another_session = create(:nasa_game_session)
        new_facilitator = build(:nasa_game_facilitator, user:, session: another_session)
        expect(new_facilitator).to be_valid
      end
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:user).class_name("User") }
    it { is_expected.to belong_to(:session).class_name("NasaGame::Session") }
  end

  describe "UUID primary key" do
    it "uses UUID as primary key" do
      facilitator = create(:nasa_game_facilitator)
      expect(facilitator.id).to be_present
      expect(facilitator.id).to match(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i)
    end
  end
end
