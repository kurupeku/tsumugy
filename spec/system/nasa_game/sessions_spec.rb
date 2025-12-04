# frozen_string_literal: true

require "rails_helper"

RSpec.describe "NasaGame::Sessions", type: :system do
  describe "セッション作成" do
    it "グループ数を指定してセッションを作成できる" do
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
  end

  describe "ダッシュボード" do
    let!(:session) { create(:nasa_game_session) }
    let!(:groups) do
      3.times.map do |i|
        create(:nasa_game_group, session: session, name: "グループ #{i + 1}", position: i)
      end
    end

    it "セッション情報とグループ一覧を表示する" do
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

    context "フェーズ進行" do
      it "ロビーから個人ワークへ進行できる" do
        visit nasa_game_session_path(session)

        expect(page).to have_button "個人ワークを開始"

        accept_confirm do
          click_button "個人ワークを開始"
        end

        expect(page).to have_content "フェーズを更新しました"
      end

      it "個人ワークからチームワークへ進行できる" do
        session.update!(phase: :individual)
        visit nasa_game_session_path(session)

        expect(page).to have_button "チームワークを開始"

        accept_confirm do
          click_button "チームワークを開始"
        end

        expect(page).to have_content "フェーズを更新しました"
      end

      it "チームワークから結果発表へ進行できる" do
        session.update!(phase: :team)
        visit nasa_game_session_path(session)

        expect(page).to have_button "結果を発表"

        accept_confirm do
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
  end
end
