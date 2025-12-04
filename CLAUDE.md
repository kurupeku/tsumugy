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

### トラブルシューティング

- Docker コンテナが起動しない場合は `tmp/pids/server.pid` を削除して再起動
- マイグレーション後はテスト DB も更新: `bin/rails db:test:prepare`
