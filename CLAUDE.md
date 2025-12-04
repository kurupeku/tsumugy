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
