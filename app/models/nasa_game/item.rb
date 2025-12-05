# frozen_string_literal: true

module NasaGame
  class Item < ActiveHash::Base
    self.data = [
      {
        id: 1,
        correct_rank: 1,
        name_ja: "酸素ボンベ（100ポンド×2本）",
        name_en: "Two 100-pound tanks of oxygen",
        reasoning_ja: "生存に最も不可欠。月には大気がなく、宇宙服内の酸素は限られている。重量約45kgも月の重力は地球の1/6のため約7.5kgに感じる",
        reasoning_en: "Most pressing survival need. The Moon has no atmosphere, and spacesuit oxygen is limited. Weight is not a major factor since Moon's gravity is 1/6 of Earth's, making each 45 kg tank feel like only 7.5 kg"
      },
      {
        id: 2,
        correct_rank: 2,
        name_ja: "水（20リットル）",
        name_en: "20 liters of water",
        reasoning_ja: "月面の昼側は約127℃に達し、激しい発汗による水分損失を補う必要がある。人体は水なしでは短時間しか生存できない",
        reasoning_en: "The lunar day side reaches about 127°C, causing tremendous fluid loss through sweating. The human body cannot survive long without water replacement"
      },
      {
        id: 3,
        correct_rank: 3,
        name_ja: "星座図（月面用）",
        name_en: "Stellar map (of the Moon's constellations)",
        reasoning_ja: "月面でも星の配置は地球と同じに見えるため、主要な航法手段となる。磁気コンパスは使えないため、星座が唯一の方位確認手段",
        reasoning_en: "Star patterns appear essentially identical on the Moon as on Earth, making this the primary means of navigation. Since magnetic compass is useless, stellar navigation is the only reliable way to determine direction"
      },
      {
        id: 4,
        correct_rank: 4,
        name_ja: "濃縮食品",
        name_en: "Food concentrate",
        reasoning_ja: "320kmの長距離移動に必要なエネルギーを効率的に補給できる。軽量かつ高カロリーで、宇宙服を着たまま摂取可能",
        reasoning_en: "Efficient means of supplying energy requirements for the 320 km journey. Lightweight and high-calorie, can be consumed while wearing a spacesuit"
      },
      {
        id: 5,
        correct_rank: 5,
        name_ja: "太陽光発電式FM送受信機",
        name_en: "Solar-powered FM receiver-transmitter",
        reasoning_ja: "母船との通信や位置確認に使用。FM波は直線見通し通信のため短距離限定だが、月面は障害物が少なく見通しが良いため有効",
        reasoning_en: "For communication with the mother ship. FM requires line-of-sight transmission and is limited to short range, but the Moon's lack of obstacles makes it effective over moderate distances"
      },
      {
        id: 6,
        correct_rank: 6,
        name_ja: "ナイロン製ロープ（15m）",
        name_en: "15 meters of nylon rope",
        reasoning_ja: "クレーターの昇降や負傷者の搬送に使用。月面の起伏は激しく、ロープなしでは安全な移動が困難な場面がある",
        reasoning_en: "Useful for scaling craters and tying injured crew members together. The Moon's terrain is rough with many craters, making rope essential for safe traversal"
      },
      {
        id: 7,
        correct_rank: 7,
        name_ja: "救急箱（注射針付き）",
        name_en: "First-aid kit with injection needles",
        reasoning_ja: "NASA宇宙服には注射用の特殊な穴があり、ビタミン剤や薬を投与可能。負傷時の応急処置に必須",
        reasoning_en: "NASA spacesuits have special apertures that allow injection needles to administer vitamins and medicines. Essential for treating injuries during the journey"
      },
      {
        id: 8,
        correct_rank: 8,
        name_ja: "パラシュートの布（絹）",
        name_en: "Parachute silk",
        reasoning_ja: "月面の昼側は太陽光が直射し約127℃に達する。大気がないため日陰がなく、絹布で日除けを作り熱射病を防ぐ",
        reasoning_en: "The lunar day side reaches about 127°C under direct sunlight. With no atmosphere to provide shade, parachute silk can be used as protection against the Sun's rays and prevent heat stroke"
      },
      {
        id: 9,
        correct_rank: 9,
        name_ja: "自動膨張式救命ボート",
        name_en: "Self-inflating life raft",
        reasoning_ja: "軍用救命ボートに内蔵のCO2ボトルは、真空中での推進力として転用可能。作用反作用の法則により、ガス噴射で移動できる",
        reasoning_en: "The CO2 bottle in military life rafts can be used for propulsion in the vacuum. By Newton's Third Law, the gas ejection provides thrust for movement across difficult terrain"
      },
      {
        id: 10,
        correct_rank: 10,
        name_ja: "信号用照明弾",
        name_en: "Signal flares",
        reasoning_ja: "母船が視界に入った際の遭難信号として使用。月には大気がないため煙は出ないが、発光による視覚的信号が有効",
        reasoning_en: "Use as distress signal when the mother ship is sighted. Since there's no atmosphere on the Moon, smoke won't work, but the light flare provides a visible signal"
      },
      {
        id: 11,
        correct_rank: 11,
        name_ja: "45口径ピストル（2丁）",
        name_en: "Two .45 caliber pistols",
        reasoning_ja: "作用反作用の法則により、発射の反動を推進力として利用可能。真空中では大気抵抗がないため有効な移動手段になり得る",
        reasoning_en: "By Newton's Third Law, the recoil from firing can be used for self-propulsion. In the vacuum with no air resistance, this becomes a viable means of movement"
      },
      {
        id: 12,
        correct_rank: 12,
        name_ja: "粉ミルク（1箱）",
        name_en: "One case of dehydrated milk",
        reasoning_ja: "濃縮食品と機能が重複し、かさばる。貴重な水を消費して溶かす必要があり、栄養価に対する効率が悪い",
        reasoning_en: "Bulkier duplication of food concentrate. Requires precious water to reconstitute, making it less efficient in terms of nutrition per unit weight and water consumption"
      },
      {
        id: 13,
        correct_rank: 13,
        name_ja: "携帯用暖房器具",
        name_en: "Portable heating unit",
        reasoning_ja: "月面の昼側は約127℃と高温のため暖房は不要。むしろ問題は暑さ対策。夜側（約-173℃）では有用だが、今回のシナリオでは優先度が低い",
        reasoning_en: "Not needed on the lighted side of the Moon where temperatures reach 127°C. The problem is heat, not cold. Would be useful on the dark side (-173°C), but not in this scenario"
      },
      {
        id: 14,
        correct_rank: 14,
        name_ja: "磁気コンパス",
        name_en: "Magnetic compass",
        reasoning_ja: "月にはグローバルな磁場が存在しないため、磁気コンパスは北を指さない。ナビゲーションには完全に無用",
        reasoning_en: "The Moon has no global magnetic field, so a magnetic compass will not point north. Completely worthless for navigation"
      },
      {
        id: 15,
        correct_rank: 15,
        name_ja: "マッチの箱",
        name_en: "Box of matches",
        reasoning_ja: "月面には酸素がなく、燃焼反応が起きないためマッチは着火しない。宇宙服内の貴重な酸素を使うことも不可能で、完全に無価値",
        reasoning_en: "Virtually worthless. There is no oxygen on the Moon to sustain combustion, so matches cannot ignite. Using precious spacesuit oxygen for this is not feasible either"
      }
    ]

    # Returns the item name based on the current locale
    def name
      I18n.locale == :ja ? name_ja : name_en
    end

    # Returns the reasoning based on the current locale
    def reasoning
      I18n.locale == :ja ? reasoning_ja : reasoning_en
    end
  end
end
