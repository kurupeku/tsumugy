# frozen_string_literal: true

require "rails_helper"

RSpec.describe "NasaGame::Landing", type: :system do
  describe "GET /nasa_game" do
    context "when user is a facilitator of an active session" do
      it "redirects to the session page" do
        # Create session as facilitator first
        visit new_nasa_game_session_path
        fill_in "group_count", with: 2
        click_button "セッションを作成"

        # Now visit landing page - should redirect to session
        visit nasa_game_root_path

        expect(page).to have_current_path(%r{/nasa_game/sessions/})
      end
    end

    context "when user is a participant of an active session (but not facilitator)" do
      let!(:session) { create(:nasa_game_session, expires_at: 1.day.from_now) }
      let!(:group) { create(:nasa_game_group, session: session) }

      it "redirects to the participant page" do
        # Join as participant first (this session was created by someone else, so user is only participant)
        visit new_nasa_game_group_participant_path(group)
        fill_in "nasa_game_participant_display_name", with: "テスト参加者"
        click_button "参加する"

        # Verify participant page is shown
        expect(page).to have_current_path(%r{/nasa_game/participants/})

        # Now visit landing page - should redirect back to participant page
        visit nasa_game_root_path

        expect(page).to have_current_path(%r{/nasa_game/participants/})
      end
    end

    context "when user has no role" do
      it "redirects to new session page" do
        visit nasa_game_root_path

        expect(page).to have_current_path(new_nasa_game_session_path)
      end
    end

    context "when accessing from home page" do
      it "navigates to NASA game via the game card" do
        visit root_path

        click_link "NASAゲーム"

        expect(page).to have_current_path(new_nasa_game_session_path)
      end

      it "navigates to NASA game via the hero button" do
        visit root_path

        click_link "ゲームを始める"

        expect(page).to have_current_path(new_nasa_game_session_path)
      end
    end
  end

  describe "expired session handling" do
    context "when accessing expired session URL directly" do
      let!(:expired_session) { create(:nasa_game_session, expires_at: 1.hour.ago) }

      it "redirects to landing page with alert" do
        visit nasa_game_session_path(expired_session)

        expect(page).to have_current_path(new_nasa_game_session_path)
        expect(page).to have_content("セッションの有効期限が切れています")
      end
    end

    context "when facilitator's session expires" do
      it "redirects to new session page after cleanup" do
        # Create session as facilitator
        visit new_nasa_game_session_path
        fill_in "group_count", with: 2
        click_button "セッションを作成"

        # Wait for redirect and get session from DB
        expect(page).to have_current_path(%r{/nasa_game/sessions/[0-9a-f-]+$})
        session = NasaGame::Session.last

        # Expire the session
        session.update!(expires_at: 1.hour.ago)

        # Visit landing page - should cleanup and redirect to new session
        visit nasa_game_root_path

        expect(page).to have_current_path(new_nasa_game_session_path)
      end
    end

    context "when participant's session expires" do
      let!(:session) { create(:nasa_game_session, expires_at: 1.day.from_now) }
      let!(:group) { create(:nasa_game_group, session: session) }

      it "redirects to new session page after cleanup" do
        # Join as participant
        visit new_nasa_game_group_participant_path(group)
        fill_in "nasa_game_participant_display_name", with: "テスト参加者"
        click_button "参加する"

        # Expire the session
        session.update!(expires_at: 1.hour.ago)

        # Visit landing page - should cleanup and redirect
        visit nasa_game_root_path

        expect(page).to have_current_path(new_nasa_game_session_path)
      end
    end
  end

  describe "invalid URL handling" do
    context "when accessing non-existent session" do
      it "redirects to landing page" do
        visit nasa_game_session_path(id: SecureRandom.uuid)

        expect(page).to have_current_path(new_nasa_game_session_path)
        expect(page).to have_content("指定されたページが見つかりませんでした")
      end
    end

    context "when accessing non-existent group" do
      it "redirects to landing page" do
        visit new_nasa_game_group_participant_path(group_id: SecureRandom.uuid)

        expect(page).to have_current_path(new_nasa_game_session_path)
        expect(page).to have_content("指定されたページが見つかりませんでした")
      end
    end

    context "when accessing non-existent participant" do
      it "redirects to landing page" do
        visit nasa_game_participant_path(id: SecureRandom.uuid)

        expect(page).to have_current_path(new_nasa_game_session_path)
        expect(page).to have_content("参加登録が必要です")
      end
    end
  end

  describe "facilitator priority over participant" do
    let!(:participant_session) { create(:nasa_game_session, expires_at: 1.day.from_now) }
    let!(:group) { create(:nasa_game_group, session: participant_session) }

    it "redirects to facilitator session when user is both" do
      # First join as participant
      visit new_nasa_game_group_participant_path(group)
      fill_in "nasa_game_participant_display_name", with: "テスト参加者"
      click_button "参加する"

      # Then create a new session as facilitator
      visit new_nasa_game_session_path
      fill_in "group_count", with: 2
      click_button "セッションを作成"

      # Get facilitator session from DB
      expect(page).to have_current_path(%r{/nasa_game/sessions/[0-9a-f-]+$})
      facilitator_session = NasaGame::Session.order(created_at: :desc).first

      # Visit landing - should go to facilitator session (priority)
      visit nasa_game_root_path

      expect(page).to have_current_path(nasa_game_session_path(facilitator_session))
    end
  end
end
