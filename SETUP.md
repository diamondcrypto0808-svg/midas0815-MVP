# ビジネス効率化プラットフォーム - セットアップガイド

## 🎉 プロジェクト構築完了

コアインフラストラクチャと基盤コンポーネントの構築が完了しました。

## 📁 作成されたファイル構成

### ルートディレクトリ
- `README.md` - プロジェクト概要とドキュメント
- `docker-compose.yml` - Docker開発環境設定
- `.gitignore` - Git除外設定
- `SETUP.md` - このファイル

### バックエンド (Rails API)
```
backend/
├── Gemfile                          # Ruby依存関係
├── Gemfile.lock
├── Dockerfile.dev                   # Docker開発環境
├── config/
│   ├── application.rb               # Rails設定
│   ├── boot.rb
│   ├── environment.rb
│   ├── database.yml                 # PostgreSQL設定
│   ├── routes.rb                    # APIルーティング
│   └── initializers/
│       ├── redis.rb                 # Redis設定
│       ├── cors.rb                  # CORS設定
│       └── devise.rb                # 認証設定
├── db/
│   ├── migrate/                     # データベースマイグレーション
│   │   ├── 20240115000001_enable_extensions.rb
│   │   ├── 20240115000002_create_users.rb
│   │   ├── 20240115000003_create_roles.rb
│   │   ├── 20240115000004_create_profiles.rb
│   │   ├── 20240115000005_create_posts.rb
│   │   ├── 20240115000006_create_comments.rb
│   │   ├── 20240115000007_create_likes.rb
│   │   ├── 20240115000008_create_contents.rb
│   │   ├── 20240115000009_create_content_versions.rb
│   │   ├── 20240115000010_create_matches.rb
│   │   ├── 20240115000011_create_match_requests.rb
│   │   ├── 20240115000012_create_notifications.rb
│   │   └── 20240115000013_create_analytics_events.rb
│   └── seeds.rb                     # 初期データ
├── app/
│   ├── models/                      # データモデル
│   │   ├── user.rb
│   │   ├── profile.rb
│   │   ├── role.rb
│   │   ├── post.rb
│   │   ├── comment.rb
│   │   ├── like.rb
│   │   ├── content.rb
│   │   ├── content_version.rb
│   │   ├── match.rb
│   │   ├── match_request.rb
│   │   ├── notification.rb
│   │   └── analytics_event.rb
│   ├── controllers/
│   │   ├── application_controller.rb
│   │   └── api/v1/
│   │       └── auth_controller.rb   # 認証API
│   └── services/
│       ├── authentication/
│       │   └── token_service.rb     # JWT トークン管理
│       └── matching/
│           └── similarity_calculator.rb  # マッチングアルゴリズム
├── config.ru
└── Rakefile
```

### フロントエンド (Next.js)
```
frontend/
├── package.json                     # Node.js依存関係
├── Dockerfile.dev                   # Docker開発環境
├── next.config.js                   # Next.js設定
├── tsconfig.json                    # TypeScript設定
├── tailwind.config.ts               # TailwindCSS設定
├── postcss.config.js
├── .env.local.example               # 環境変数テンプレート
└── src/
    ├── app/
    │   ├── layout.tsx               # ルートレイアウト
    │   ├── page.tsx                 # ホームページ
    │   └── globals.css              # グローバルスタイル
    ├── components/
    │   └── providers.tsx            # React Query プロバイダー
    └── lib/
        └── api/
            └── client.ts            # API クライアント
```

## 🚀 セットアップ手順

### 1. 環境変数の設定

```bash
# フロントエンド
cp frontend/.env.local.example frontend/.env.local
```

### 2. Dockerでの起動

```bash
# すべてのサービスを起動
docker-compose up -d

# ログを確認
docker-compose logs -f

# データベースのセットアップ
docker-compose exec backend bundle install
docker-compose exec backend rails db:create db:migrate db:seed
```

### 3. アクセス

- **フロントエンド**: http://localhost:3001
- **バックエンドAPI**: http://localhost:3000
- **PostgreSQL**: localhost:5432
- **Redis**: localhost:6379

## 📊 データベース構造

### 主要テーブル

1. **users** - ユーザー情報（Devise認証）
2. **profiles** - ユーザープロフィール
3. **roles** - 役割（admin, user）
4. **posts** - SNS投稿
5. **comments** - 投稿へのコメント
6. **likes** - いいね
7. **contents** - CMS コンテンツ
8. **content_versions** - コンテンツバージョン履歴
9. **matches** - 確立済みマッチ
10. **match_requests** - マッチングリクエスト
11. **notifications** - 通知
12. **analytics_events** - 分析イベント

## 🔐 認証システム

### JWT トークン認証

- **アクセストークン**: 15分有効
- **リフレッシュトークン**: 7日間有効
- Redis でトークン管理

### APIエンドポイント

```
POST /api/v1/auth/register          # ユーザー登録
POST /api/v1/auth/login             # ログイン
POST /api/v1/auth/logout            # ログアウト
POST /api/v1/auth/refresh           # トークン更新
POST /api/v1/auth/password/reset    # パスワードリセット要求
PUT  /api/v1/auth/password          # パスワード更新
```

## 👤 デフォルトユーザー

シードデータで以下のユーザーが作成されます：

### 管理者
- **Email**: admin@example.com
- **Password**: Admin123!@#

### 一般ユーザー
- **Email**: user1@example.com ~ user5@example.com
- **Password**: User123!@#

## 🧪 テスト

### バックエンド

```bash
# RSpec テスト
docker-compose exec backend bundle exec rspec

# プロパティベーステスト
docker-compose exec backend bundle exec rspec spec/**/*_property_spec.rb
```

### フロントエンド

```bash
# Jest ユニットテスト
docker-compose exec frontend npm run test

# E2E テスト
docker-compose exec frontend npm run test:e2e
```

## 📝 次のステップ

### 実装予定の機能

1. **ユーザー管理**
   - [ ] プロフィール編集画面
   - [ ] アバター画像アップロード
   - [ ] 権限管理画面

2. **SNS機能**
   - [ ] タイムライン表示
   - [ ] 投稿作成フォーム
   - [ ] いいね・コメント機能

3. **CMS機能**
   - [ ] コンテンツエディタ
   - [ ] バージョン管理UI
   - [ ] 公開管理

4. **マッチング機能**
   - [ ] 候補表示
   - [ ] リクエスト送信
   - [ ] マッチ一覧

5. **分析機能**
   - [ ] ダッシュボード
   - [ ] グラフ表示
   - [ ] レポート生成

6. **検索機能**
   - [ ] 全文検索
   - [ ] フィルタリング

7. **通知機能**
   - [ ] リアルタイム通知
   - [ ] 通知一覧
   - [ ] 設定画面

## 🛠️ 開発コマンド

### Docker

```bash
# サービス起動
docker-compose up -d

# サービス停止
docker-compose down

# ログ確認
docker-compose logs -f [service_name]

# コンテナに入る
docker-compose exec backend bash
docker-compose exec frontend sh

# データベースリセット
docker-compose exec backend rails db:reset
```

### Rails

```bash
# マイグレーション
rails db:migrate

# ロールバック
rails db:rollback

# コンソール
rails console

# ルート確認
rails routes
```

### Next.js

```bash
# 開発サーバー
npm run dev

# ビルド
npm run build

# 本番起動
npm run start
```

## 📚 参考資料

- [要件定義書](.kiro/specs/business-efficiency-platform/requirements.md)
- [設計書](.kiro/specs/business-efficiency-platform/design.md)
- [Rails Guides](https://guides.rubyonrails.org/)
- [Next.js Documentation](https://nextjs.org/docs)

## 🐛 トラブルシューティング

### ポートが既に使用されている

```bash
# ポートを使用しているプロセスを確認
lsof -i :3000
lsof -i :3001
lsof -i :5432

# プロセスを終了
kill -9 [PID]
```

### データベース接続エラー

```bash
# PostgreSQLコンテナの状態確認
docker-compose ps db

# データベース再作成
docker-compose exec backend rails db:drop db:create db:migrate db:seed
```

### Redisエラー

```bash
# Redisコンテナの状態確認
docker-compose ps redis

# Redis再起動
docker-compose restart redis
```

## 📞 サポート

問題が発生した場合は、以下を確認してください：

1. すべてのサービスが起動しているか: `docker-compose ps`
2. ログにエラーがないか: `docker-compose logs`
3. 環境変数が正しく設定されているか

---

**構築完了日**: 2024年1月15日
**バージョン**: 0.1.0
