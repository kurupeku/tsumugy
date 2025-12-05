# frozen_string_literal: true

require "rails_helper"

RSpec.describe "NasaGame::Participants", type: :system do
  let!(:session) { create(:nasa_game_session, phase: :lobby) }
  let!(:group) { create(:nasa_game_group, session: session, name: "テストグループ", position: 0) }

  describe "グループ参加" do
    it "表示名を入力してグループに参加できる", :aggregate_failures do
      visit new_nasa_game_group_participant_path(group)

      expect(page).to have_content "NASAゲーム"
      expect(page).to have_content "テストグループ"
      expect(page).to have_content "に参加します"

      fill_in "nasa_game_participant_display_name", with: "テスト太郎"
      click_button "参加する"

      expect(page).to have_content "グループに参加しました"
      expect(page).to have_content "待機中"
    end

    it "既存の参加者が表示される" do
      create(:nasa_game_participant, group: group, session: session, display_name: "既存ユーザー")

      visit new_nasa_game_group_participant_path(group)

      expect(page).to have_content "参加中のメンバー"
      expect(page).to have_content "既存ユーザー"
    end
  end

  describe "ロビー画面" do
    it "参加者一覧とミッション概要が表示される", :aggregate_failures do
      join_group_as("テスト太郎")

      expect(page).to have_content "テストグループ"
      expect(page).to have_content "待機中"
      expect(page).to have_content "テスト太郎"
      expect(page).to have_content "ミッション概要を見る"
    end

    it "他の参加者も表示される" do
      create(:nasa_game_participant, group: group, session: session, display_name: "他のユーザー")

      visit new_nasa_game_group_participant_path(group)
      fill_in "nasa_game_participant_display_name", with: "テスト太郎"
      click_button "参加する"

      expect(page).to have_content "他のユーザー"
    end
  end

  describe "個人ワーク画面" do
    it "15個のアイテムが表示される" do
      # Join in lobby phase first
      participant_path = join_group_as("テスト太郎")

      # Change to individual phase
      session.reload.update!(phase: :individual)

      # Refresh page to see individual work
      visit participant_path

      expect(page).to have_content "個人ワーク"
      expect(page).to have_content "アイテムを重要な順に並べ替えてください"

      # All 15 items should be present
      NasaGame::Item.all.each do |item|
        expect(page).to have_content item.name_ja
      end
    end

    it "確定ボタンが表示される" do
      participant_path = join_group_as("テスト太郎")
      session.reload.update!(phase: :individual)
      visit participant_path

      expect(page).to have_button "この順位で確定する"
    end

    it "個人ワークを確定できる" do
      participant_path = join_group_as("テスト太郎")
      session.reload.update!(phase: :individual)
      visit participant_path

      accept_custom_confirm do
        click_button "この順位で確定する"
      end

      expect(page).to have_content "個人ワークを完了しました"
      expect(page).to have_content "完了済み"
    end
  end

  describe "チームワーク画面" do
    it "チームランキングとメンバー参照が表示される", :aggregate_failures do
      participant_path = complete_individual_work_as("テスト太郎")
      session.reload.update!(phase: :team)
      visit participant_path

      expect(page).to have_content "テストグループ"
      expect(page).to have_content "グループで話し合いながら"
      expect(page).to have_content "メンバーの個人ランキングを参照"
    end

    it "確定ボタンが表示される" do
      participant_path = complete_individual_work_as("テスト太郎")
      session.reload.update!(phase: :team)
      visit participant_path

      expect(page).to have_button "この順位で確定する"
    end

    it "チームランキングを確定できる" do
      participant_path = complete_individual_work_as("テスト太郎")
      session.reload.update!(phase: :team)
      visit participant_path

      accept_custom_confirm do
        click_button "この順位で確定する"
      end

      expect(page).to have_content "チームランキングを確定しました"
      expect(page).to have_content "完了済み"
      expect(page).not_to have_button "この順位で確定する"
    end

    it "確定後はランキング編集不可になる" do
      participant_path = complete_individual_work_as("テスト太郎")
      session.reload.update!(phase: :team)
      visit participant_path

      accept_custom_confirm do
        click_button "この順位で確定する"
      end

      expect(page).to have_content "チームワークは完了しています"
      # Check that sortable is disabled (no drag handle)
      expect(page).not_to have_css("[data-controller='sortable']")
    end

    it "既に確定済みの場合は確定ボタンが表示されない" do
      # First, mark group as already completed
      participant_path = complete_individual_work_as("テスト太郎")
      session.reload.update!(phase: :team)
      group.update!(completed_at: Time.current)

      # Visit team work page as the participant
      visit participant_path

      # Should show completed state without confirm button
      expect(page).to have_content "完了済み"
      expect(page).to have_content "チームワークは完了しています"
      expect(page).not_to have_button "この順位で確定する"
    end
  end

  describe "結果画面" do
    before do
      # Create group rankings for result calculation
      NasaGame::Item.all.each_with_index do |item, index|
        create(:nasa_game_group_ranking,
               group: group,
               item_id: item.id,
               rank: index + 1)
      end
    end

    it "スコアと結果が表示される", :aggregate_failures do
      participant_path = complete_individual_work_as("テスト太郎")
      session.reload.update!(phase: :result)
      visit participant_path

      expect(page).to have_content "結果発表"
      expect(page).to have_content "あなたの個人スコア"
      expect(page).to have_content "チームスコア"
      expect(page).to have_content "シナジー効果"
      expect(page).to have_content "NASAの解説"
    end

    it "詳細比較テーブルが表示される", :aggregate_failures do
      participant_path = complete_individual_work_as("テスト太郎")
      session.reload.update!(phase: :result)
      visit participant_path

      expect(page).to have_content "正解"
      expect(page).to have_content "個人"
      expect(page).to have_content "チーム"
      expect(page).to have_content "誤差"
    end

    it "トップに戻るボタンがある" do
      participant_path = complete_individual_work_as("テスト太郎")
      session.reload.update!(phase: :result)
      visit participant_path

      expect(page).to have_link "トップに戻る"
    end
  end

  private

  # Helper to join group via form submission (sets cookie properly)
  # Returns the participant show path after joining
  def join_group_as(display_name)
    visit new_nasa_game_group_participant_path(group)
    fill_in "nasa_game_participant_display_name", with: display_name
    click_button "参加する"
    current_path
  end

  # Helper to complete individual work phase
  # Returns the participant show path after completing
  def complete_individual_work_as(display_name)
    participant_path = join_group_as(display_name)
    session.reload.update!(phase: :individual)
    visit participant_path
    accept_custom_confirm { click_button "この順位で確定する" }
    participant_path
  end
end
