# frozen_string_literal: true

require "rails_helper"

RSpec.describe NasaGame::Group, type: :model do
  describe "validations" do
    subject(:group) { build(:nasa_game_group) }

    it "is valid with valid attributes" do
      expect(group).to be_valid
    end

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:position) }
    it { is_expected.to validate_numericality_of(:position).only_integer.is_greater_than_or_equal_to(0) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:session).class_name("NasaGame::Session") }
    it { is_expected.to have_many(:participants).class_name("NasaGame::Participant").dependent(:destroy) }
    it { is_expected.to have_many(:group_rankings).class_name("NasaGame::GroupRanking").dependent(:destroy) }
  end

  describe "UUID primary key" do
    it "uses UUID as primary key" do
      session = create(:nasa_game_session)
      group = described_class.create!(session: session, name: "Group A", position: 0)
      expect(group.id).to be_present
      expect(group.id).to match(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i)
    end
  end

  describe "completed_at" do
    subject(:group) { create(:nasa_game_group) }

    it "is nil by default" do
      expect(group.completed_at).to be_nil
    end

    it "can be set to mark group work as completed" do
      group.update!(completed_at: Time.current)
      expect(group.completed_at).to be_present
    end
  end

  describe "#completed?" do
    subject(:group) { create(:nasa_game_group) }

    it "returns false when completed_at is nil" do
      expect(group).not_to be_completed
    end

    it "returns true when completed_at is set" do
      group.update!(completed_at: Time.current)
      expect(group).to be_completed
    end
  end
end
