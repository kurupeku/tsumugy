# frozen_string_literal: true

module NasaGame
  class Item < ActiveHash::Base
    self.data = [
      {
        id: 1,
        correct_rank: 1,
        name_ja: "酸素ボンベ（100ポンド×2本）",
        name_en: "Two 100-pound tanks of oxygen",
        reasoning_ja: "生存に最も不可欠。月には大気がない",
        reasoning_en: "Most pressing survival need; the Moon has no atmosphere"
      },
      {
        id: 2,
        correct_rank: 2,
        name_ja: "水（20リットル）",
        name_en: "20 liters of water",
        reasoning_ja: "高温による発汗で水分損失を補う",
        reasoning_en: "Replacement of water lost through sweating caused by high temperatures"
      },
      {
        id: 3,
        correct_rank: 3,
        name_ja: "星座図（月面用）",
        name_en: "Stellar map (of the Moon's constellations)",
        reasoning_ja: "主要な航法手段。コンパスは使えない",
        reasoning_en: "Primary means of navigation; compass is useless on the Moon"
      },
      {
        id: 4,
        correct_rank: 4,
        name_ja: "濃縮食品",
        name_en: "Food concentrate",
        reasoning_ja: "エネルギー補給の効率的手段",
        reasoning_en: "Efficient means of supplying energy"
      },
      {
        id: 5,
        correct_rank: 5,
        name_ja: "太陽光発電式FM送受信機",
        name_en: "Solar-powered FM receiver-transmitter",
        reasoning_ja: "短距離通信用",
        reasoning_en: "For short-range communication"
      },
      {
        id: 6,
        correct_rank: 6,
        name_ja: "ナイロン製ロープ（15m）",
        name_en: "15 meters of nylon rope",
        reasoning_ja: "移動補助、負傷者搬送",
        reasoning_en: "Useful for climbing craters and tying injured"
      },
      {
        id: 7,
        correct_rank: 7,
        name_ja: "救急箱（注射針付き）",
        name_en: "First-aid kit with injection needles",
        reasoning_ja: "負傷時の手当て",
        reasoning_en: "Injection needle could administer medicine through suit"
      },
      {
        id: 8,
        correct_rank: 8,
        name_ja: "パラシュートの布（絹）",
        name_en: "Parachute silk",
        reasoning_ja: "日除け、熱射病対策",
        reasoning_en: "Shelter against the Sun's rays"
      },
      {
        id: 9,
        correct_rank: 9,
        name_ja: "自動膨張式救命ボート",
        name_en: "Self-inflating life raft",
        reasoning_ja: "CO2ボトルを推進力として転用可能",
        reasoning_en: "CO2 bottle in raft could be used for propulsion"
      },
      {
        id: 10,
        correct_rank: 10,
        name_ja: "信号用照明弾",
        name_en: "Signal flares",
        reasoning_ja: "視覚的遭難信号",
        reasoning_en: "Distress signal when in line of sight"
      },
      {
        id: 11,
        correct_rank: 11,
        name_ja: "45口径ピストル（2丁）",
        name_en: "Two .45 caliber pistols",
        reasoning_ja: "反動を推進力として転用可能",
        reasoning_en: "Could be used for propulsion with recoil"
      },
      {
        id: 12,
        correct_rank: 12,
        name_ja: "粉ミルク（1箱）",
        name_en: "One case of dehydrated milk",
        reasoning_ja: "濃縮食品と重複、非効率",
        reasoning_en: "Bulkier duplication of food concentrate"
      },
      {
        id: 13,
        correct_rank: 13,
        name_ja: "携帯用暖房器具",
        name_en: "Portable heating unit",
        reasoning_ja: "昼間なので不要",
        reasoning_en: "Not needed on the lighted side of the Moon"
      },
      {
        id: 14,
        correct_rank: 14,
        name_ja: "磁気コンパス",
        name_en: "Magnetic compass",
        reasoning_ja: "月には磁場がないため無効",
        reasoning_en: "Worthless for navigation; the Moon has no magnetic field"
      },
      {
        id: 15,
        correct_rank: 15,
        name_ja: "マッチの箱",
        name_en: "Box of matches",
        reasoning_ja: "酸素がないため火がつかない",
        reasoning_en: "No oxygen to sustain flame"
      }
    ]
  end
end
