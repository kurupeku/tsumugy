# frozen_string_literal: true

require "rails_helper"

RSpec.describe "NasaGame::Sessions", type: :system do
  describe "セッション作成" do
    it "グループ数を指定してセッションを作成できる", :aggregate_failures do
      visit new_nasa_game_session_path

      expect(page).to have_content "NASAゲーム"
      expect(page).to have_content "月面からの脱出"

      fill_in "group_count", with: 3
      click_button "セッションを作成"

      expect(page).to have_content "セッションを作成しました"
      expect(page).to have_content "フェーズ管理"
      expect(page).to have_content "グループ 1"
      expect(page).to have_content "グループ 2"
      expect(page).to have_content "グループ 3"
    end

    it "デフォルトで4グループが設定されている" do
      visit new_nasa_game_session_path

      expect(page).to have_field("group_count", with: "4")
    end

    it "ゲーム選択画面へ戻るリンクが表示される" do
      visit new_nasa_game_session_path

      expect(page).to have_link "ゲーム選択に戻る", href: root_path
    end

    it "ゲーム選択に戻るリンクからトップページに遷移できる" do
      visit new_nasa_game_session_path

      click_link "ゲーム選択に戻る"

      expect(page).to have_current_path(root_path)
    end
  end

  describe "ダッシュボード" do
    let!(:session) { create(:nasa_game_session) }
    let!(:groups) do
      3.times.map do |i|
        create(:nasa_game_group, session: session, name: "グループ #{i + 1}", position: i)
      end
    end

    it "セッション情報とグループ一覧を表示する", :aggregate_failures do
      visit nasa_game_session_path(session)

      expect(page).to have_content "フェーズ管理"
      expect(page).to have_content "ロビー"
      expect(page).to have_content "グループ一覧"
      expect(page).to have_content "3グループ"

      groups.each do |group|
        expect(page).to have_content group.name
      end
    end

    it "招待URLをコピーできる" do
      visit nasa_game_session_path(session)

      # Each group should have an invite URL input
      groups.each do |group|
        expect(page).to have_field("invite-url-#{group.id}", readonly: true)
      end
    end

    context "when progressing through phases" do
      it "ロビーから個人ワークへ進行できる" do
        visit nasa_game_session_path(session)

        expect(page).to have_button "個人ワークを開始"

        accept_custom_confirm do
          click_button "個人ワークを開始"
        end

        expect(page).to have_content "フェーズを更新しました"
      end

      it "個人ワークからチームワークへ進行できる" do
        session.update!(phase: :individual)
        visit nasa_game_session_path(session)

        expect(page).to have_button "チームワークを開始"

        accept_custom_confirm do
          click_button "チームワークを開始"
        end

        expect(page).to have_content "フェーズを更新しました"
      end

      it "チームワークから結果発表へ進行できる" do
        session.update!(phase: :team)
        visit nasa_game_session_path(session)

        expect(page).to have_button "結果を発表"

        accept_custom_confirm do
          click_button "結果を発表"
        end

        expect(page).to have_content "フェーズを更新しました"
      end

      it "結果発表フェーズでは完了バッジが表示される" do
        session.update!(phase: :result)
        visit nasa_game_session_path(session)

        expect(page).to have_content "完了"
      end
    end

    context "when terminating session" do
      # Facilitator is created when visiting the dashboard via browser
      # which triggers current_user creation and facilitator association
      # For these tests, we need to create the session through the UI first

      it "ヘッダーの終了ボタンでセッションを終了できる" do
        # Create session through UI to establish facilitator relationship
        visit new_nasa_game_session_path
        fill_in "group_count", with: 2
        click_button "セッションを作成"

        # Wait for redirect and get session from current URL
        expect(page).to have_content "セッションを作成しました"
        session_id = current_path.split("/").last
        created_session = NasaGame::Session.find(session_id)

        # Dismiss toast before clicking navbar button
        dismiss_toasts

        # Click the end session button in navbar and accept confirm dialog
        accept_custom_confirm do
          within(".navbar") { click_button "セッションを終了" }
        end

        expect(page).to have_current_path(root_path)
        expect(NasaGame::Session.exists?(created_session.id)).to be false
      end

      it "結果発表フェーズでは目立つ終了ボタンが表示される" do
        # Create session through UI
        visit new_nasa_game_session_path
        fill_in "group_count", with: 2
        click_button "セッションを作成"
        expect(page).to have_content "セッションを作成しました"

        # Progress through phases via UI to reach result phase
        # Lobby -> Individual
        accept_custom_confirm { click_button "個人ワークを開始" }
        expect(page).to have_content "フェーズを更新しました"

        # Individual -> Team
        accept_custom_confirm { click_button "チームワークを開始" }
        expect(page).to have_content "フェーズを更新しました"

        # Team -> Result
        accept_custom_confirm { click_button "結果を発表" }
        expect(page).to have_content "フェーズを更新しました"

        # Result phase has a prominent end button (btn-error btn-lg)
        expect(page).to have_css(".btn-error.btn-lg", text: "セッションを終了")

        session_id = current_path.split("/").last
        created_session = NasaGame::Session.find(session_id)

        accept_custom_confirm do
          find(".btn-error.btn-lg", text: "セッションを終了").click
        end

        expect(page).to have_current_path(root_path)
        expect(NasaGame::Session.exists?(created_session.id)).to be false
      end

      it "セッション終了時に関連データも削除される" do
        # Create session through UI
        visit new_nasa_game_session_path
        fill_in "group_count", with: 2
        click_button "セッションを作成"
        expect(page).to have_content "セッションを作成しました"

        # Get session info from URL path
        session_id = current_path.split("/").last
        created_session = NasaGame::Session.find(session_id)

        # Groups are created through UI, get them after page load
        group_ids = created_session.groups.pluck(:id)
        expect(group_ids.size).to eq(2)

        # Dismiss toast before clicking navbar button
        dismiss_toasts

        accept_custom_confirm do
          within(".navbar") { click_button "セッションを終了" }
        end

        expect(page).to have_current_path(root_path)
        expect(NasaGame::Session.exists?(created_session.id)).to be false
        group_ids.each do |group_id|
          expect(NasaGame::Group.exists?(group_id)).to be false
        end
      end
    end
  end
end
