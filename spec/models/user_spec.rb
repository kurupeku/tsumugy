# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    subject(:user) { build(:user) }

    it "is valid with valid attributes" do
      expect(user).to be_valid
    end

    # NOTE: session_token is auto-generated, so we test uniqueness only
    it { is_expected.to validate_uniqueness_of(:session_token) }
  end

  describe "associations" do
    it { is_expected.to have_many(:nasa_game_participants).class_name("NasaGame::Participant").dependent(:destroy) }
    it { is_expected.to have_many(:nasa_game_facilitators).class_name("NasaGame::Facilitator").dependent(:destroy) }
  end

  describe "UUID primary key" do
    it "uses UUID as primary key" do
      user = create(:user)
      expect(user.id).to be_present
      expect(user.id).to match(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i)
    end
  end

  describe "session_token" do
    it "generates a unique session_token before validation if not present" do
      user = build(:user, session_token: nil)
      user.valid?
      expect(user.session_token).to be_present
    end

    it "does not overwrite existing session_token" do
      existing_token = SecureRandom.urlsafe_base64(32)
      user = build(:user, session_token: existing_token)
      user.valid?
      expect(user.session_token).to eq(existing_token)
    end
  end

  describe "expires_at" do
    it "sets default expires_at to 1 day from now on create" do
      user = create(:user, expires_at: nil)
      expect(user.expires_at).to be_within(1.second).of(1.day.from_now)
    end
  end

  describe "#extend_expiration!" do
    it "extends expires_at to 1 day from now" do
      user = create(:user, expires_at: 1.hour.ago)
      user.extend_expiration!
      expect(user.expires_at).to be_within(1.second).of(1.day.from_now)
    end
  end

  describe "#expired?" do
    it "returns true when expires_at is in the past" do
      user = build(:user, expires_at: 1.hour.ago)
      expect(user).to be_expired
    end

    it "returns false when expires_at is in the future" do
      user = build(:user, expires_at: 1.hour.from_now)
      expect(user).not_to be_expired
    end
  end

  describe "scopes" do
    describe ".expired" do
      it "returns users with expires_at in the past" do
        expired_user = create(:user, expires_at: 1.hour.ago)
        active_user = create(:user, expires_at: 1.hour.from_now)

        expect(described_class.expired).to include(expired_user)
        expect(described_class.expired).not_to include(active_user)
      end
    end

    describe ".active" do
      it "returns users with expires_at in the future" do
        expired_user = create(:user, expires_at: 1.hour.ago)
        active_user = create(:user, expires_at: 1.hour.from_now)

        expect(described_class.active).to include(active_user)
        expect(described_class.active).not_to include(expired_user)
      end
    end
  end
end
