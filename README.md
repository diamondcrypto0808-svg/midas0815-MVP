# ビジネス効率化プラットフォーム

業務効率化と顧客サービス向上を目的とした包括的なWebアプリケーションプラットフォーム。

## 機能概要

- **ユーザー管理**: 登録、認証、プロフィール管理、権限管理
- **データ分析**: イベントトラッキング、ダッシュボード、レポート生成
- **CMS**: コンテンツ作成・編集、バージョン管理、公開管理
- **SNS**: 投稿、タイムライン、いいね、コメント
- **マッチング**: アルゴリズムベースのユーザーマッチング

## 技術スタック

### フロントエンド
- Next.js 14+ (App Router)
- React 18+
- TypeScript 5+
- TailwindCSS 3+
- Radix UI / shadcn/ui

### バックエンド
- Ruby on Rails 7.1+
- Ruby 3.2+
- PostgreSQL 15+
- Redis 7+
- Sidekiq

## プロジェクト構成

```
.
├── backend/          # Rails API
├── frontend/         # Next.js アプリケーション
├── docker-compose.yml
└── README.md
```

## セットアップ

### 前提条件

- Docker & Docker Compose
- Node.js 20+ (ローカル開発の場合)
- Ruby 3.2+ (ローカル開発の場合)

### Docker での起動

```bash
# すべてのサービスを起動
docker-compose up -d

# データベースのセットアップ
docker-compose exec backend rails db:create db:migrate db:seed

# フロントエンドにアクセス
open http://localhost:3001

# バックエンドAPIにアクセス
open http://localhost:3000
```

### ローカル開発

#### バックエンド

```bash
cd backend
bundle install
rails db:create db:migrate db:seed
rails server
```

#### フロントエンド

```bash
cd frontend
npm install
npm run dev
```

## テスト

### バックエンド

```bash
cd backend
bundle exec rspec
```

### フロントエンド

```bash
cd frontend
npm run test
npm run test:e2e
```

## デプロイ

本番環境へのデプロイはGitHub Actionsを使用したCI/CDパイプラインで自動化されています。

詳細は `.github/workflows/deploy.yml` を参照してください。

## ドキュメント

- [要件定義書](.kiro/specs/business-efficiency-platform/requirements.md)
- [設計書](.kiro/specs/business-efficiency-platform/design.md)
- [API仕様書](backend/docs/api.md)

## ライセンス

Proprietary
