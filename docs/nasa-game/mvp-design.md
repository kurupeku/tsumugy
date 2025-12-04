# NASA ゲーム MVP 設計書

## 概要

NASA「月面からの脱出」ゲームの MVP 実装設計。チームビルディング演習をウェブアプリ化する。

## 設計方針

1. **名前空間分離**: `NasaGame::` で全モデル・コントローラーを囲む（将来の別ゲーム追加時の衝突回避）
2. **UUID 主キー**: 全テーブルで UUID を使用（推測不可能な URL）
3. **ActiveHash**: 静的データ（15 アイテム）は DB に入れず ActiveHash で管理
4. **RESTful**: Rails Way に沿った URL 設計
5. **アプリ共通 User**: Cookie 管理をアプリ全体で統一し、各ゲームの参加者と紐づける

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
      |                           (User 自動作成)
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
User (アプリ共通)
  |-- session_token (Cookie 識別用, unique)
  |-- expires_at (有効期限)
  |-- timestamps
  |
  +-- NasaGame::Facilitator (セッション作成者)
  +-- NasaGame::Participant (各ゲームへの参加)

NasaGame::Item (ActiveHash)
  - 15個のアイテム静的データ
  - correct_rank, reasoning を持つ

NasaGame::Session
  |-- phase (enum)
  |-- expires_at (有効期限、デフォルト24時間)
  |
  +-- NasaGame::Facilitator (セッション作成者)
  |     |-- user_id (FK -> users)
  |
  +-- NasaGame::Group (複数)
  |     |-- name, position
  |     |-- completed_at
  |     +-- NasaGame::GroupRanking (15件)
  |
  +-- NasaGame::Participant (複数)
        |-- user_id (FK -> users)
        |-- display_name
        |-- group_id (所属グループ)
        |-- individual_completed_at
        +-- NasaGame::IndividualRanking (15件)
```

### User モデルの役割

- **アプリ全体で 1 つの Cookie** で識別（ゲームごとの Cookie 管理が不要）
- 初回アクセス時に自動作成、Cookie に `session_token` を保存
- 各ゲームの `Participant` は `User` に紐づく
- 将来の別ゲーム追加時も同じ `User` を再利用可能

## データベーステーブル

全テーブル UUID 主キー。

### users（アプリ共通）

- id: uuid (PK)
- session_token: string (unique, not null)
- expires_at: datetime (default: now + 1 day)
- timestamps

### nasa_game_sessions

- id: uuid (PK)
- phase: integer (enum, default: 0)
- expires_at: datetime (default: now + 1 day)
- timestamps

### nasa_game_facilitators

- id: uuid (PK)
- user_id: uuid (FK -> users)
- session_id: uuid (FK -> nasa_game_sessions)
- timestamps
- unique index: [user_id, session_id]

### nasa_game_groups

- id: uuid (PK)
- session_id: uuid (FK -> nasa_game_sessions)
- name: string
- position: integer
- completed_at: datetime (null 可)
- timestamps

### nasa_game_participants

- id: uuid (PK)
- user_id: uuid (FK -> users)
- session_id: uuid (FK -> nasa_game_sessions)
- group_id: uuid (FK -> nasa_game_groups)
- display_name: string
- individual_completed_at: datetime (null 可)
- timestamps
- unique index: [user_id, session_id] （1 ユーザー 1 セッションに 1 参加）

### nasa_game_individual_rankings

- id: uuid (PK)
- participant_id: uuid (FK -> nasa_game_participants)
- item_id: integer (ActiveHash ID)
- rank: integer (1-15)
- timestamps
- unique index: [participant_id, item_id]

### nasa_game_group_rankings

- id: uuid (PK)
- group_id: uuid (FK -> nasa_game_groups)
- item_id: integer (ActiveHash ID)
- rank: integer (1-15)
- timestamps
- unique index: [group_id, item_id]

## URL 設計

```
# ファシリテーター
/nasa_game/sessions/new              # セッション作成
/nasa_game/sessions/:id              # ダッシュボード（ファシリテーター用）

# 参加者フロー
/nasa_game/groups/:group_id/participants/new    # 参加フォーム（招待リンク）
/nasa_game/groups/:group_id/participants        # POST: 参加登録
/nasa_game/participants/:id                     # 参加者画面（フェーズに応じて表示切替）

# ランキング操作
/nasa_game/participants/:participant_id/individual_rankings  # 個人ランキング
/nasa_game/groups/:group_id/group_rankings                   # グループランキング
```

## ユーザー識別

### 認証フロー

1. ユーザーが参加フォームにアクセス
2. Cookie に `session_token` がなければ `User` を自動作成
3. Cookie に `session_token` を保存（httponly, 1 日有効）
4. 参加フォーム送信時に `User` と `Participant` を紐づけ
5. 以降のアクセスは Cookie から `User` → `Participant` を特定

### 認証 Concern

```ruby
# app/controllers/concerns/user_authentication.rb
module UserAuthentication
  COOKIE_KEY = :tsumugy_session_token

  def current_user
    @current_user ||= find_or_create_user_from_cookie
  end

  private

  def find_or_create_user_from_cookie
    token = cookies.signed[COOKIE_KEY]
    user = User.find_by(session_token: token) if token
    user || create_and_store_user
  end

  def create_and_store_user
    user = User.create!
    cookies.signed[COOKIE_KEY] = {
      value: user.session_token,
      expires: 1.day.from_now,
      httponly: true
    }
    user
  end
end
```

## リアルタイム同期（MVP 後）

Action Cable を使用予定。

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
- リアルタイム同期（Action Cable）

## 技術スタック

- Rails 8.0 + Ruby 3.4
- PostgreSQL 16 (UUID 拡張)
- Hotwire (Turbo + Stimulus)
- Tailwind CSS 4 + DaisyUI 5 (Puma plugin で CSS ビルド)
- ActiveHash
- RSpec + FactoryBot + Playwright (System Specs)

## 実装進捗

### 完了

- [x] プロジェクト初期設定（Rails 8.0, Tailwind CSS 4, DaisyUI 5）
- [x] Docker Compose 環境構築
- [x] Puma plugin による Tailwind CSS ビルド設定
- [x] NasaGame::Item (ActiveHash) - 15 アイテム静的データ
- [x] NasaGame::Session モデル + フェーズ enum
- [x] NasaGame::Group モデル
- [x] NasaGame::Participant モデル
- [x] NasaGame::IndividualRanking モデル
- [x] NasaGame::GroupRanking モデル
- [x] 参加者用ビュー（ロビー、個人ワーク、チームワーク、結果）
- [x] ファシリテーター用ビュー（セッション作成、ダッシュボード）
- [x] モデル単体テスト (RSpec)
- [x] System テスト基盤 (Playwright)
- [x] User モデル導入（アプリ共通 Cookie 管理 + expires_at による有効期限管理）
- [x] NasaGame::Participant を User に紐づけるリファクタリング
- [x] System テスト修正（User ベースの認証フロー）
- [x] NasaGame::Facilitator モデル導入（セッション作成者の追跡）
- [x] NasaGame::Session に expires_at 追加（24 時間有効期限）
- [x] Landing Controller（役割ベースの自動リダイレクト）
- [x] 期限切れセッションの自動クリーンアップ（Landing アクセス時）

### 未着手

- [ ] リアルタイム同期 (Action Cable)
- [ ] 期限切れユーザーのクリーンアップバッチ（MVP 後対応）

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
