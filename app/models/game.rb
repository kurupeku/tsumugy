# frozen_string_literal: true

# Game master data using ActiveHash
# Manages game information for the top page game selection
class Game < ActiveHash::Base
  self.data = [
    {
      id: 1,
      slug: "nasa_game",
      name_ja: "NASAゲーム",
      name_en: "NASA Game",
      subtitle_ja: "月面からの脱出",
      subtitle_en: "Escape from the Moon",
      short_description_ja: "月面からの脱出 - チームで協力してアイテムの優先順位を決めよう",
      short_description_en: "Escape from the Moon - Work together to prioritize survival items",
      description_ja: "あなたは月面に不時着した宇宙飛行士です。母船にたどり着くために、手元に残った15個のアイテムに優先順位をつけなければなりません。まずは個人でランキングを作成し、その後チームで議論して最終的な順位を決定します。NASAの公式回答と比較して、チームワークの効果を体感しましょう。",
      description_en: "You are an astronaut who crash-landed on the moon. To reach the mother ship, you must prioritize 15 items at hand. First, create individual rankings, then discuss as a team to determine the final order. Compare with NASA's official answer to experience the power of teamwork.",
      players_ja: "4〜8人",
      players_en: "4-8 players",
      duration_ja: "30〜45分",
      duration_en: "30-45 min",
      flow_steps_ja: [
        "ファシリテーターがセッションを作成",
        "参加者がグループに参加",
        "個人ワーク: 各自でアイテムをランキング",
        "チームワーク: グループで話し合い最終順位を決定",
        "結果発表: NASAの公式回答と比較"
      ],
      flow_steps_en: [
        "Facilitator creates a session",
        "Participants join groups",
        "Individual work: Rank items on your own",
        "Team work: Discuss and decide final ranking",
        "Results: Compare with NASA's official answer"
      ],
      icon: "🌙",
      icon_bg_class: "bg-primary/20",
      image_path: "games/nasa-game.png",
      start_path: "nasa_game_root_path",
      available: true
    },
    {
      id: 2,
      slug: "coming_soon_1",
      name_ja: "Coming Soon",
      name_en: "Coming Soon",
      subtitle_ja: "新しいゲームを準備中",
      subtitle_en: "New game coming soon",
      short_description_ja: "新しいゲームを準備中です",
      short_description_en: "New games are being prepared",
      description_ja: "",
      description_en: "",
      players_ja: "",
      players_en: "",
      duration_ja: "",
      duration_en: "",
      flow_steps_ja: [],
      flow_steps_en: [],
      icon: "🎲",
      icon_bg_class: "bg-secondary/20",
      image_path: nil,
      start_path: nil,
      available: false
    },
    {
      id: 3,
      slug: "coming_soon_2",
      name_ja: "Coming Soon",
      name_en: "Coming Soon",
      subtitle_ja: "新しいゲームを準備中",
      subtitle_en: "New game coming soon",
      short_description_ja: "新しいゲームを準備中です",
      short_description_en: "New games are being prepared",
      description_ja: "",
      description_en: "",
      players_ja: "",
      players_en: "",
      duration_ja: "",
      duration_en: "",
      flow_steps_ja: [],
      flow_steps_en: [],
      icon: "🏆",
      icon_bg_class: "bg-accent/20",
      image_path: nil,
      start_path: nil,
      available: false
    }
  ]

  # Returns games that are available to play
  def self.available
    all.select(&:available?)
  end

  # Returns games that are coming soon
  def self.coming_soon
    all.reject(&:available?)
  end

  # Locale-aware accessors
  def name
    I18n.locale == :ja ? name_ja : name_en
  end

  def subtitle
    I18n.locale == :ja ? subtitle_ja : subtitle_en
  end

  def short_description
    I18n.locale == :ja ? short_description_ja : short_description_en
  end

  def description
    I18n.locale == :ja ? description_ja : description_en
  end

  def players
    I18n.locale == :ja ? players_ja : players_en
  end

  def duration
    I18n.locale == :ja ? duration_ja : duration_en
  end

  def flow_steps
    I18n.locale == :ja ? flow_steps_ja : flow_steps_en
  end

  # Check if game is available
  def available?
    available == true
  end

  # Check if game has an image
  def has_image?
    image_path.present?
  end
end
