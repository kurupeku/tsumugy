# Tsumugy

チームビルディングゲームプラットフォーム

## 技術スタック

- Ruby 3.4 / Rails 8.0
- Tailwind CSS 4 + DaisyUI 5
- Hotwire (Turbo + Stimulus)
- PostgreSQL 16 (Docker Compose)
- pnpm (JavaScript パッケージ管理)

## 開発コマンド

```bash
docker compose up -d           # コンテナ起動
docker compose down            # コンテナ停止
docker compose logs -f app     # ログ確認
docker compose exec app bin/rails c          # Rails コンソール
docker compose exec app bin/rails db:migrate # マイグレーション実行
```

## ディレクトリ構成

- `app/assets/tailwind/application.css` - Tailwind/DaisyUI 設定
- `app/views/` - ERB テンプレート (DaisyUI コンポーネント使用)
- `package.json` - pnpm 管理の JS パッケージ

## 規約

- DaisyUI コンポーネントを積極的に活用する
- Stimulus でインタラクティブな機能を実装

## ユーザー認証アーキテクチャ

### 概要

本アプリケーションは揮発性の高い匿名ユーザーモデルを採用している。ログイン不要で Cookie ベースのセッション管理を行う。

### User モデル

- **1:1 関係（アプリ全体）**: 1 つのブラウザセッションに対して 1 つの User レコード
- **1:N 関係（ゲーム）**: 1 User は複数のゲーム参加者（例: `NasaGame::Participant`）を持つ

```ruby
# User モデル
class User < ApplicationRecord
  SESSION_DURATION = 1.day

  has_many :nasa_game_participants, dependent: :destroy
  # 将来追加されるゲームの参加者も同様に関連付け
end
```

### 揮発性セッション管理

- `session_token`: Cookie に保存される一意のトークン
- `expires_at`: セッション有効期限（デフォルト 1 日）
- アクセスごとに `extend_expiration!` で有効期限を延長
- 有効期限切れの User は定期バッチで削除（将来実装）

### UserAuthentication Concern

```ruby
# app/controllers/concerns/user_authentication.rb
module UserAuthentication
  COOKIE_KEY = :tsumugy_session_token

  def current_user
    # Cookie から User を取得、なければ新規作成
  end
end
```

- アプリ全体で共通利用
- ゲーム固有の認証（例: `ParticipantAuthentication`）はこれを include して拡張

### 新規ゲーム追加時のパターン

1. 参加者モデルに `belongs_to :user` を追加
2. User モデルに `has_many :new_game_participants` を追加
3. ゲーム固有の認証 Concern で `UserAuthentication` を include
4. `current_user` を使って参加者を取得

## ゲームセッション終了パターン

### 共通動作

ファシリテーターがセッションを終了する際の共通動作:

1. 確認ダイアログを表示（誤操作防止）
2. セッションと関連データを全て削除
3. トップページ（`/`）にリダイレクト

### 実装パターン

- コントローラーに `destroy` アクションを追加
- ファシリテーター権限チェックを `before_action` で実施
- ビューでは `data: { turbo_confirm: "..." }` で確認ダイアログを表示
- 削除後は `root_path` にリダイレクト（ゲーム固有のランディングではなくアプリのトップ）

### 新規ゲーム追加時

1. セッションコントローラーに `destroy` アクションを追加
2. ファシリテーターダッシュボードに「セッションを終了」ボタンを配置
3. 確認ダイアログのメッセージはゲームに応じて調整

## モデル実装方針

### 名前空間とテーブル名

- 機能単位でモジュール（名前空間）を使用する（例: `NasaGame::Session`）
- 名前空間モジュールに `table_name_prefix` を定義してテーブル名プレフィックスを設定する

  ```ruby
  # app/models/nasa_game.rb
  module NasaGame
    def self.table_name_prefix
      "nasa_game_"
    end
  end
  ```

- 個別モデルで `self.table_name` を指定する必要はない

### マイグレーション

- 主キーは UUID を使用: `create_table :table_name, id: :uuid`
- 外部キーは名前空間付きテーブルを明示指定:

  ```ruby
  t.references :session, null: false, foreign_key: { to_table: :nasa_game_sessions }, type: :uuid
  ```

- `foreign_key: true` は Rails が `sessions` テーブルを参照しようとするため使用しない

### アソシエーション

- 名前空間付きモデルは `class_name` と `inverse_of` を明示指定:

  ```ruby
  belongs_to :session, class_name: "NasaGame::Session", inverse_of: :participants
  has_many :participants, class_name: "NasaGame::Participant", foreign_key: :session_id, dependent: :destroy, inverse_of: :session
  ```

- 関連モデルの `has_many`/`belongs_to` は、関連先モデルの作成時に追加する（先に存在しないモデルへの関連を書かない）

### 静的データ

- マスターデータなど変更頻度の低いデータには `active_hash` gem を使用
- `ActiveHash::Base` を継承して `self.data` に配列で定義

### テスト

- TDD 方式: テスト作成 → 実装 → テスト通過 → 次のクラス
- RSpec + FactoryBot + shoulda-matchers を使用
- テスト実行前に `bin/rails db:test:prepare` でテスト DB を準備
- ファクトリは名前空間に合わせてディレクトリを分割: `spec/factories/nasa_game/`
- ファクトリ名はプレフィックスをつける: `nasa_game_session`, `nasa_game_participant` など

#### スペックの種類

本プロジェクトでは以下のスペックのみを使用する:

- **モデルスペック** (`spec/models/`): ActiveRecord モデルのバリデーション、アソシエーション、スコープ、メソッドのテスト
- **PORO スペック**: サービスクラスや ActiveHash など、ActiveRecord 以外のクラスのテスト
- **システムスペック** (`spec/system/`): ブラウザを使った E2E テスト（Capybara + Playwright）

以下のスペックは使用しない:

- リクエストスペック (`spec/requests/`)
- コントローラースペック (`spec/controllers/`)
- ビュースペック (`spec/views/`)
- ヘルパースペック (`spec/helpers/`)

コントローラーのロジックはシステムスペックでカバーする。

### トラブルシューティング

- Docker コンテナが起動しない場合は `tmp/pids/server.pid` を削除して再起動
- マイグレーション後はテスト DB も更新: `bin/rails db:test:prepare`
