# NASA ゲーム MVP 設計書

## 概要

NASA「月面からの脱出」ゲームの MVP 実装設計。チームビルディング演習をウェブアプリ化する。

## 設計方針

1. **名前空間分離**: `NasaGame::` で全モデル・コントローラーを囲む（将来の別ゲーム追加時の衝突回避）
2. **UUID 主キー**: 全テーブルで UUID を使用（推測不可能な URL）
3. **ActiveHash**: 静的データ（15 アイテム）は DB に入れず ActiveHash で管理
4. **RESTful**: Rails Way に沿った URL 設計

## ゲームフロー

```
ファシリテーター                     参加者
      |                               |
  セッション作成                       |
  (グループ数指定)                     |
      |                               |
  グループURL共有 ──────────────────→ URL クリック
      |                               |
      |                           表示名入力
      |                               |
      |                           グループ参加
      |                               |
  ダッシュボード                   ロビー待機
  (全グループ俯瞰)                     |
      |                               |
  「個人ワーク開始」                   |
      |                               |
      └─────────────────────────────→ 個人ワーク
                                      |
                                  ランク付け
                                      |
                                  「確定」
                                      |
                                  チームワーク
                                      |
                                  グループ協議
                                      |
                                  誰か1人が「確定」
                                      |
      └─────────────────────────────→ 結果画面
```

## フェーズ管理

| Phase | 名前       | 説明           |
| ----- | ---------- | -------------- |
| 0     | lobby      | ロビー待機中   |
| 1     | individual | 個人ワーク中   |
| 2     | team       | チームワーク中 |
| 3     | result     | 結果表示       |

- 開始はファシリテーターが「開始」ボタンを押下
- 個人ワーク完了は各自が「確定」ボタン押下
- チームワーク完了はファシリテーターが全グループ一括で「確定」
- ファシリテーターの終了押下でゲームセッション終了

## ドメインモデル

```
NasaGame::Item (ActiveHash)
  - 15個のアイテム静的データ
  - correct_rank, reasoning を持つ

NasaGame::Session
  |-- phase (enum)
  |
  +-- NasaGame::Group (複数)
  |     |-- name, position
  |     |-- completed_at
  |     +-- NasaGame::GroupRanking (15件)
  |
  +-- NasaGame::Participant (複数)
        |-- session_token (Cookie識別用)
        |-- display_name
        |-- group_id (所属グループ)
        |-- individual_completed_at
        +-- NasaGame::IndividualRanking (15件)
```

## データベーステーブル

全テーブル UUID 主キー、テーブル名は `nasa_game_` プレフィックス。

### nasa_game_sessions

- id: uuid (PK)
- phase: integer (enum)
- timestamps

### nasa_game_groups

- id: uuid (PK)
- session_id: uuid (FK)
- name: string
- position: integer
- completed_at: datetime (null 可)
- timestamps

### nasa_game_participants

- id: uuid (PK)
- session_id: uuid (FK)
- group_id: uuid (FK)
- session_token: string (unique)
- display_name: string
- individual_completed_at: datetime (null 可)
- timestamps

### nasa_game_individual_rankings

- id: uuid (PK)
- participant_id: uuid (FK)
- item_id: integer (ActiveHash ID)
- rank: integer (1-15)
- timestamps
- unique index: [participant_id, item_id]

### nasa_game_group_rankings

- id: uuid (PK)
- group_id: uuid (FK)
- item_id: integer (ActiveHash ID)
- rank: integer (1-15)
- timestamps
- unique index: [group_id, item_id]

## URL 設計

```
/nasa_game/sessions/new          # セッション作成
/nasa_game/sessions/:id          # セッション詳細（リダイレクト用）
/nasa_game/sessions/:id/dashboard  # ファシリテーター用ダッシュボード

/nasa_game/groups/:id/join       # 参加画面
/nasa_game/groups/:id/lobby      # ロビー
/nasa_game/groups/:id/individual_work  # 個人ワーク
/nasa_game/groups/:id/team_work  # チームワーク
/nasa_game/groups/:id/result     # 結果
```

## ユーザー識別

- ユーザー登録なし（ゲスト参加）
- `session_token` を Cookie に保存して識別
- グループ移動時は個人ワークをリセット

## リアルタイム同期

Action Cable を使用。

### NasaGame::SessionChannel

- フェーズ遷移通知
- 参加者入退室通知

### NasaGame::GroupChannel

- チームワーク時のランキング同期
- アイテムロック/アンロック

## スコア計算

```
誤差スコア = Σ |正解順位 - 回答順位|
シナジー = 個人平均スコア - グループスコア
```

### 判定基準

| スコア | 判定      |
| ------ | --------- |
| 0-25   | Excellent |
| 26-32  | Good      |
| 33-45  | Average   |
| 46-55  | Fair      |
| 56-70  | Poor      |
| 71-112 | Very Poor |

## MVP 除外機能

- タイマー
- チャット/ボイス
- 合意スタンプ
- アクティビティログ
- エクスポート
- グラフ表示
- アバター
- ファシリテーター認証
- データ永続化（セッション終了後削除）

## 技術スタック

- Rails 8.0 + Ruby 3.4
- PostgreSQL 16 (UUID 拡張)
- Hotwire (Turbo + Stimulus)
- Action Cable (Solid Cable)
- Tailwind CSS 4 + DaisyUI 5
- ActiveHash

## 15 アイテム正解データ

| Rank | アイテム                       | 理由                               |
| ---- | ------------------------------ | ---------------------------------- |
| 1    | 酸素ボンベ（100 ポンド ×2 本） | 生存に最も不可欠。月には大気がない |
| 2    | 水（20 リットル）              | 高温による発汗で水分損失を補う     |
| 3    | 星座図（月面用）               | 主要な航法手段。コンパスは使えない |
| 4    | 濃縮食品                       | エネルギー補給の効率的手段         |
| 5    | 太陽光発電式 FM 送受信機       | 短距離通信用                       |
| 6    | ナイロン製ロープ（15m）        | 移動補助、負傷者搬送               |
| 7    | 救急箱（注射針付き）           | 負傷時の手当て                     |
| 8    | パラシュートの布（絹）         | 日除け、熱射病対策                 |
| 9    | 自動膨張式救命ボート           | CO2 ボトルを推進力として転用可能   |
| 10   | 信号用照明弾                   | 視覚的遭難信号                     |
| 11   | 45 口径ピストル（2 丁）        | 反動を推進力として転用可能         |
| 12   | 粉ミルク（1 箱）               | 濃縮食品と重複、非効率             |
| 13   | 携帯用暖房器具                 | 昼間なので不要                     |
| 14   | 磁気コンパス                   | 月には磁場がないため無効           |
| 15   | マッチの箱                     | 酸素がないため火がつかない         |
