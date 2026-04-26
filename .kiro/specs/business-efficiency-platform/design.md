# 設計書：ビジネス効率化プラットフォーム

## 概要

本設計書は、ビジネス効率化プラットフォームの技術設計を定義します。本システムは、ユーザー管理、データ分析、コンテンツ管理、SNS、マッチング機能を統合した包括的なWebアプリケーションです。

### 技術スタック

**フロントエンド:**
- Next.js 14+ (App Router)
- React 18+
- TypeScript 5+
- TailwindCSS 3+ (スタイリング)
- Radix UI / shadcn/ui (UIコンポーネント)
- React Hook Form + Zod (フォーム管理・バリデーション)
- TanStack Query (データフェッチング・キャッシング)
- Zustand (グローバル状態管理)

**バックエンド:**
- Ruby on Rails 7.1+
- Ruby 3.2+
- PostgreSQL 15+ (メインデータベース)
- Redis (セッション・キャッシュ・ジョブキュー)
- Sidekiq (バックグラウンドジョブ)
- Action Cable (WebSocket/リアルタイム通信)

**インフラ・DevOps:**
- Docker & Docker Compose (開発環境)
- AWS (本番環境想定)
  - EC2 / ECS (アプリケーションホスティング)
  - RDS (PostgreSQL)
  - ElastiCache (Redis)
  - S3 (画像・ファイルストレージ)
  - CloudFront (CDN)
  - SES (メール送信)
- GitHub Actions (CI/CD)

### 設計原則

1. **セキュリティファースト**: すべてのレイヤーでセキュリティを考慮
2. **パフォーマンス重視**: 高速なレスポンスとスムーズなUX
3. **スケーラビリティ**: ユーザー増加に対応可能なアーキテクチャ
4. **保守性**: クリーンなコード、適切な抽象化、包括的なテスト
5. **アクセシビリティ**: WCAG 2.1 AA準拠
6. **日本語ネイティブ**: すべてのUIとメッセージを日本語で提供

## アーキテクチャ

### システムアーキテクチャ図

\`\`\`mermaid
graph TB
    subgraph "クライアント層"
        Browser[Webブラウザ]
        Mobile[モバイルブラウザ]
    end
    
    subgraph "CDN層"
        CloudFront[CloudFront CDN]
    end
    
    subgraph "フロントエンド層"
        NextJS[Next.js App<br/>SSR/SSG/ISR]
        StaticAssets[静的アセット<br/>画像・CSS・JS]
    end
    
    subgraph "API層"
        Rails[Rails API<br/>REST + GraphQL]
        ActionCable[Action Cable<br/>WebSocket]
    end
    
    subgraph "ビジネスロジック層"
        UserMgmt[User Management<br/>Module]
        Analytics[Analytics<br/>Module]
        CMS[CMS<br/>Module]
        SNS[SNS<br/>Module]
        Matching[Matching<br/>Module]
    end
    
    subgraph "データ層"
        PostgreSQL[(PostgreSQL<br/>メインDB)]
        Redis[(Redis<br/>キャッシュ・セッション)]
        S3[(S3<br/>ファイルストレージ)]
    end
    
    subgraph "バックグラウンド処理"
        Sidekiq[Sidekiq<br/>ジョブワーカー]
    end
    
    subgraph "外部サービス"
        SES[AWS SES<br/>メール送信]
    end
    
    Browser --> CloudFront
    Mobile --> CloudFront
    CloudFront --> NextJS
    CloudFront --> StaticAssets
    NextJS --> Rails
    NextJS --> ActionCable
    Rails --> UserMgmt
    Rails --> Analytics
    Rails --> CMS
    Rails --> SNS
    Rails --> Matching
    UserMgmt --> PostgreSQL
    Analytics --> PostgreSQL
    CMS --> PostgreSQL
    SNS --> PostgreSQL
    Matching --> PostgreSQL
    Rails --> Redis
    ActionCable --> Redis
    Rails --> S3
    Rails --> Sidekiq
    Sidekiq --> PostgreSQL
    Sidekiq --> SES
\`\`\`

### レイヤー構成

#### 1. プレゼンテーション層（Next.js）

**責務:**
- UIレンダリング（SSR/SSG/CSR）
- ユーザーインタラクション処理
- クライアントサイドルーティング
- フォームバリデーション
- 状態管理

**主要コンポーネント:**
- Pages/Routes (App Router)
- React Components (Atomic Design)
- API Route Handlers (BFF パターン)
- Middleware (認証・国際化)

#### 2. API層（Rails）

**責務:**
- RESTful API提供
- GraphQL API提供（複雑なクエリ用）
- 認証・認可
- リクエストバリデーション
- レスポンス整形

**エンドポイント設計:**
- `/api/v1/*` - REST API
- `/graphql` - GraphQL API
- `/cable` - WebSocket (Action Cable)

#### 3. ビジネスロジック層（Rails Services/Interactors）

**責務:**
- ビジネスルール実装
- データ処理・変換
- トランザクション管理
- イベント発行

**モジュール構成:**
- User Management Module
- Analytics Module
- CMS Module
- SNS Module
- Matching Module

#### 4. データアクセス層（Rails Models/Repositories）

**責務:**
- データベースアクセス
- データ整合性保証
- クエリ最適化
- キャッシング

### モジュール設計

#### User Management Module

**機能:**
- ユーザー登録・認証
- プロフィール管理
- 権限管理
- セッション管理

**主要クラス:**
- `User` (Model)
- `Profile` (Model)
- `Role` (Model)
- `AuthenticationService` (Service)
- `RegistrationService` (Service)
- `ProfileUpdateService` (Service)

#### Analytics Module

**機能:**
- イベントトラッキング
- データ集計・分析
- ダッシュボード表示
- レポート生成

**主要クラス:**
- `AnalyticsEvent` (Model)
- `Dashboard` (Model)
- `EventCollector` (Service)
- `DataAggregator` (Service)
- `ReportGenerator` (Service)

#### CMS Module

**機能:**
- コンテンツ作成・編集
- バージョン管理
- 公開管理
- メディア管理

**主要クラス:**
- `Content` (Model)
- `ContentVersion` (Model)
- `MediaAsset` (Model)
- `ContentPublisher` (Service)
- `VersionManager` (Service)

#### SNS Module

**機能:**
- 投稿作成・表示
- タイムライン生成
- いいね・コメント
- リアルタイム更新

**主要クラス:**
- `Post` (Model)
- `Comment` (Model)
- `Like` (Model)
- `Timeline` (Model)
- `PostCreator` (Service)
- `TimelineGenerator` (Service)

#### Matching Module

**機能:**
- マッチングアルゴリズム
- 候補生成
- リクエスト管理
- マッチ確立

**主要クラス:**
- `Match` (Model)
- `MatchRequest` (Model)
- `MatchingAlgorithm` (Service)
- `SimilarityCalculator` (Service)
- `MatchRequestHandler` (Service)

## コンポーネントとインターフェース

### フロントエンドコンポーネント構成

#### Atomic Design階層

\`\`\`
src/
├── components/
│   ├── atoms/           # 最小単位のコンポーネント
│   │   ├── Button/
│   │   ├── Input/
│   │   ├── Label/
│   │   ├── Avatar/
│   │   └── Badge/
│   ├── molecules/       # 原子の組み合わせ
│   │   ├── FormField/
│   │   ├── SearchBar/
│   │   ├── UserCard/
│   │   └── PostCard/
│   ├── organisms/       # 分子の組み合わせ
│   │   ├── Header/
│   │   ├── Sidebar/
│   │   ├── PostForm/
│   │   ├── Timeline/
│   │   └── MatchingList/
│   ├── templates/       # ページレイアウト
│   │   ├── MainLayout/
│   │   ├── AuthLayout/
│   │   └── DashboardLayout/
│   └── pages/           # 完全なページ
│       ├── HomePage/
│       ├── ProfilePage/
│       └── DashboardPage/
\`\`\`

### API インターフェース設計

#### REST API エンドポイント

**認証・ユーザー管理:**
\`\`\`
POST   /api/v1/auth/register          # ユーザー登録
POST   /api/v1/auth/login             # ログイン
POST   /api/v1/auth/logout            # ログアウト
POST   /api/v1/auth/password/reset    # パスワードリセット要求
PUT    /api/v1/auth/password          # パスワード更新

GET    /api/v1/users/:id              # ユーザー詳細取得
PUT    /api/v1/users/:id              # ユーザー更新
GET    /api/v1/users/:id/profile      # プロフィール取得
PUT    /api/v1/users/:id/profile      # プロフィール更新
POST   /api/v1/users/:id/avatar       # アバター画像アップロード
\`\`\`

**コンテンツ管理:**
\`\`\`
GET    /api/v1/contents               # コンテンツ一覧
POST   /api/v1/contents               # コンテンツ作成
GET    /api/v1/contents/:id           # コンテンツ詳細
PUT    /api/v1/contents/:id           # コンテンツ更新
DELETE /api/v1/contents/:id           # コンテンツ削除
POST   /api/v1/contents/:id/publish   # コンテンツ公開
GET    /api/v1/contents/:id/versions  # バージョン履歴
POST   /api/v1/contents/:id/revert    # バージョン復元
\`\`\`

**SNS:**
\`\`\`
GET    /api/v1/posts                  # 投稿一覧（タイムライン）
POST   /api/v1/posts                  # 投稿作成
GET    /api/v1/posts/:id              # 投稿詳細
DELETE /api/v1/posts/:id              # 投稿削除
POST   /api/v1/posts/:id/like         # いいね
DELETE /api/v1/posts/:id/like         # いいね解除
GET    /api/v1/posts/:id/comments     # コメント一覧
POST   /api/v1/posts/:id/comments     # コメント投稿
\`\`\`

**マッチング:**
\`\`\`
GET    /api/v1/matches/candidates     # マッチング候補取得
POST   /api/v1/matches/requests       # マッチングリクエスト送信
GET    /api/v1/matches/requests       # リクエスト一覧
PUT    /api/v1/matches/requests/:id   # リクエスト承認/拒否
GET    /api/v1/matches                # 確立済みマッチ一覧
\`\`\`

**分析:**
\`\`\`
GET    /api/v1/analytics/dashboard    # ダッシュボードデータ
GET    /api/v1/analytics/events       # イベントデータ
POST   /api/v1/analytics/events       # イベント記録
GET    /api/v1/analytics/reports      # レポート取得
\`\`\`

**検索:**
\`\`\`
GET    /api/v1/search                 # 全文検索
GET    /api/v1/search/users           # ユーザー検索
GET    /api/v1/search/posts           # 投稿検索
GET    /api/v1/search/contents        # コンテンツ検索
\`\`\`

**通知:**
\`\`\`
GET    /api/v1/notifications          # 通知一覧
PUT    /api/v1/notifications/:id/read # 既読マーク
PUT    /api/v1/notifications/settings # 通知設定更新
\`\`\`

#### リクエスト/レスポンス形式

**標準レスポンス形式:**
\`\`\`json
{
  "success": true,
  "data": { ... },
  "meta": {
    "page": 1,
    "per_page": 20,
    "total": 100
  }
}
\`\`\`

**エラーレスポンス形式:**
\`\`\`json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "入力内容に誤りがあります",
    "details": [
      {
        "field": "email",
        "message": "メールアドレスの形式が正しくありません"
      }
    ]
  }
}
\`\`\`

### WebSocket インターフェース（Action Cable）

**チャンネル:**
\`\`\`
NotificationChannel      # リアルタイム通知
TimelineChannel          # タイムライン更新
MatchingChannel          # マッチング通知
\`\`\`

**メッセージ形式:**
\`\`\`json
{
  "type": "notification",
  "action": "new_like",
  "data": {
    "post_id": 123,
    "user_id": 456,
    "message": "あなたの投稿にいいねがつきました"
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
\`\`\`

## データモデル

### ER図

\`\`\`mermaid
erDiagram
    users ||--o{ profiles : has
    users ||--o{ posts : creates
    users ||--o{ comments : writes
    users ||--o{ likes : gives
    users ||--o{ match_requests : sends
    users ||--o{ match_requests : receives
    users ||--o{ matches : participates
    users ||--o{ notifications : receives
    users ||--o{ analytics_events : generates
    users }o--o{ roles : has
    
    posts ||--o{ comments : has
    posts ||--o{ likes : receives
    posts ||--o{ media_attachments : includes
    
    contents ||--o{ content_versions : has
    contents ||--o{ media_assets : includes
    
    match_requests ||--o| matches : creates
    
    users {
        bigint id PK
        string email UK
        string encrypted_password
        string confirmation_token
        datetime confirmed_at
        datetime created_at
        datetime updated_at
    }
    
    profiles {
        bigint id PK
        bigint user_id FK
        string display_name
        text bio
        string avatar_url
        jsonb interests
        jsonb skills
        jsonb preferences
        datetime created_at
        datetime updated_at
    }
    
    roles {
        bigint id PK
        string name
        text description
        datetime created_at
        datetime updated_at
    }
    
    posts {
        bigint id PK
        bigint user_id FK
        text content
        integer likes_count
        integer comments_count
        datetime created_at
        datetime updated_at
    }
    
    comments {
        bigint id PK
        bigint post_id FK
        bigint user_id FK
        text content
        datetime created_at
        datetime updated_at
    }
    
    likes {
        bigint id PK
        bigint post_id FK
        bigint user_id FK
        datetime created_at
    }
    
    contents {
        bigint id PK
        bigint author_id FK
        string title
        text body
        string status
        string slug UK
        datetime published_at
        datetime created_at
        datetime updated_at
    }
    
    content_versions {
        bigint id PK
        bigint content_id FK
        integer version_number
        text body
        jsonb metadata
        datetime created_at
    }
    
    media_assets {
        bigint id PK
        string attachable_type
        bigint attachable_id
        string file_url
        string file_type
        integer file_size
        jsonb metadata
        datetime created_at
    }
    
    matches {
        bigint id PK
        bigint user1_id FK
        bigint user2_id FK
        float similarity_score
        datetime matched_at
        datetime created_at
    }
    
    match_requests {
        bigint id PK
        bigint sender_id FK
        bigint receiver_id FK
        string status
        text message
        datetime created_at
        datetime updated_at
    }
    
    notifications {
        bigint id PK
        bigint user_id FK
        string notification_type
        string title
        text message
        jsonb data
        boolean read
        datetime read_at
        datetime created_at
    }
    
    analytics_events {
        bigint id PK
        bigint user_id FK
        string event_type
        string event_category
        jsonb properties
        datetime created_at
    }
\`\`\`

### 主要モデル詳細

#### User (ユーザー)

\`\`\`ruby
class User < ApplicationRecord
  # Devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :timeoutable

  # Associations
  has_one :profile, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :sent_match_requests, class_name: 'MatchRequest', 
           foreign_key: 'sender_id', dependent: :destroy
  has_many :received_match_requests, class_name: 'MatchRequest', 
           foreign_key: 'receiver_id', dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :analytics_events, dependent: :destroy
  has_and_belongs_to_many :roles

  # Validations
  validates :email, presence: true, uniqueness: true, 
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, 
            format: { with: /\A(?=.*[a-zA-Z])(?=.*\d)(?=.*[@$!%*?&])/,
                     message: "英数字と記号を含める必要があります" },
            if: :password_required?

  # Callbacks
  after_create :create_default_profile
  after_create :assign_default_role

  # Scopes
  scope :active, -> { where(locked_at: nil) }
  scope :admins, -> { joins(:roles).where(roles: { name: 'admin' }) }

  # Methods
  def admin?
    roles.exists?(name: 'admin')
  end

  private

  def create_default_profile
    create_profile!
  end

  def assign_default_role
    roles << Role.find_by(name: 'user') unless roles.any?
  end
end
\`\`\`

#### Profile (プロフィール)

\`\`\`ruby
class Profile < ApplicationRecord
  belongs_to :user

  # Validations
  validates :display_name, length: { maximum: 50 }
  validates :bio, length: { maximum: 500 }

  # Attachments
  has_one_attached :avatar

  # Methods
  def avatar_url
    avatar.attached? ? Rails.application.routes.url_helpers.url_for(avatar) : nil
  end

  def interests_list
    interests || []
  end

  def skills_list
    skills || []
  end
end
\`\`\`

#### Post (投稿)

\`\`\`ruby
class Post < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many_attached :images

  # Validations
  validates :content, presence: true, length: { maximum: 3000 }
  validate :images_count_limit

  # Callbacks
  after_create :notify_followers
  after_create_commit :broadcast_to_timeline

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :popular, -> { order(likes_count: :desc) }

  # Methods
  def liked_by?(user)
    likes.exists?(user: user)
  end

  private

  def images_count_limit
    errors.add(:images, "は5枚までです") if images.count > 5
  end

  def broadcast_to_timeline
    TimelineChannel.broadcast_to(user, {
      type: 'new_post',
      post: PostSerializer.new(self).as_json
    })
  end
end
\`\`\`

#### Content (コンテンツ)

\`\`\`ruby
class Content < ApplicationRecord
  belongs_to :author, class_name: 'User'
  has_many :content_versions, dependent: :destroy
  has_many_attached :media_files

  # Enums
  enum status: { draft: 0, published: 1, archived: 2 }

  # Validations
  validates :title, presence: true, length: { maximum: 200 }
  validates :slug, presence: true, uniqueness: true
  validates :body, presence: true

  # Callbacks
  before_validation :generate_slug, if: :title_changed?
  after_update :create_version, if: :body_changed?

  # Scopes
  scope :published, -> { where(status: :published) }
  scope :recent, -> { order(published_at: :desc) }

  # Methods
  def publish!
    update!(status: :published, published_at: Time.current)
  end

  def revert_to_version(version_number)
    version = content_versions.find_by(version_number: version_number)
    return false unless version

    update!(body: version.body)
  end

  private

  def generate_slug
    self.slug = title.parameterize
  end

  def create_version
    content_versions.create!(
      version_number: content_versions.count + 1,
      body: body_was,
      metadata: { updated_by: Current.user&.id }
    )
  end
end
\`\`\`

#### Match (マッチ)

\`\`\`ruby
class Match < ApplicationRecord
  belongs_to :user1, class_name: 'User'
  belongs_to :user2, class_name: 'User'

  # Validations
  validates :user1_id, uniqueness: { scope: :user2_id }
  validate :users_must_be_different

  # Callbacks
  after_create :notify_users

  # Scopes
  scope :for_user, ->(user_id) {
    where('user1_id = ? OR user2_id = ?', user_id, user_id)
  }

  # Methods
  def other_user(current_user)
    current_user.id == user1_id ? user2 : user1
  end

  private

  def users_must_be_different
    errors.add(:base, "同じユーザー同士はマッチできません") if user1_id == user2_id
  end

  def notify_users
    [user1, user2].each do |user|
      NotificationService.create_notification(
        user: user,
        type: 'match_established',
        title: '新しいマッチが成立しました',
        data: { match_id: id }
      )
    end
  end
end
\`\`\`

### データベースインデックス戦略

\`\`\`ruby
# db/migrate/xxx_add_indexes.rb
class AddIndexes < ActiveRecord::Migration[7.1]
  def change
    # Users
    add_index :users, :email, unique: true
    add_index :users, :confirmation_token, unique: true
    add_index :users, :created_at

    # Profiles
    add_index :profiles, :user_id, unique: true

    # Posts
    add_index :posts, :user_id
    add_index :posts, :created_at
    add_index :posts, [:user_id, :created_at]
    add_index :posts, :likes_count

    # Comments
    add_index :comments, :post_id
    add_index :comments, :user_id
    add_index :comments, [:post_id, :created_at]

    # Likes
    add_index :likes, [:post_id, :user_id], unique: true
    add_index :likes, :user_id

    # Contents
    add_index :contents, :slug, unique: true
    add_index :contents, :status
    add_index :contents, :published_at
    add_index :contents, [:status, :published_at]

    # Matches
    add_index :matches, [:user1_id, :user2_id], unique: true
    add_index :matches, :user2_id
    add_index :matches, :similarity_score

    # Match Requests
    add_index :match_requests, :sender_id
    add_index :match_requests, :receiver_id
    add_index :match_requests, :status

    # Notifications
    add_index :notifications, :user_id
    add_index :notifications, [:user_id, :read]
    add_index :notifications, :created_at

    # Analytics Events
    add_index :analytics_events, :user_id
    add_index :analytics_events, :event_type
    add_index :analytics_events, :created_at
    add_index :analytics_events, [:event_type, :created_at]

    # Full-text search (PostgreSQL)
    add_index :posts, :content, using: :gin, 
              opclass: :gin_trgm_ops
    add_index :contents, :body, using: :gin, 
              opclass: :gin_trgm_ops
  end
end
\`\`\`

## 正確性プロパティ（Correctness Properties）

本セクションでは、システムが満たすべき普遍的な性質を定義します。

*プロパティとは、システムのすべての有効な実行において真であるべき特性や振る舞いのことです。本質的には、システムが何をすべきかについての形式的な記述です。プロパティは、人間が読める仕様と機械で検証可能な正確性保証の橋渡しとなります。*

### プロパティ適用可能性の評価

本プラットフォームは以下の特性を持ちます：

**PBTが適用可能な領域:**
- マッチングアルゴリズム（類似度計算、候補生成）
- 検索機能（全文検索、フィルタリング）
- データバリデーション（入力検証、制約チェック）
- データ変換ロジック（シリアライゼーション、正規化）

**PBTが適用不可能な領域:**
- UI レンダリング → スナップショットテスト使用
- CRUD操作 → 例ベースの統合テスト使用
- 外部サービス連携（メール送信、ファイルアップロード）→ モックベースのテスト使用
- リアルタイム通信（WebSocket）→ 統合テスト使用

以下、PBTが適用可能な領域についてプロパティを定義します。


### プロパティリフレクション（冗長性の排除）

prework分析で特定されたプロパティを確認し、冗長性を排除します：

**特定されたプロパティ:**
1. マッチング類似度計算の対称性と範囲
2. マッチング候補のソート順序
3. 検索結果のソート順序
4. 検索結果のフィルタリング正確性
5. パスワード暗号化の一方向性
6. 投稿文字数バリデーション
7. パスワード強度バリデーション

**冗長性分析:**
- プロパティ2（マッチング候補ソート）とプロパティ3（検索結果ソート）は、どちらもソート順序の検証ですが、異なるドメイン（マッチング vs 検索）に適用されるため、両方とも保持します
- その他のプロパティはそれぞれ独立した検証価値を持つため、すべて保持します

**結論:** すべてのプロパティが独自の検証価値を提供するため、冗長性はありません。

### 正確性プロパティ定義

#### プロパティ1: マッチング類似度の対称性と範囲

*任意の*2つのユーザープロフィールに対して、類似度計算は以下を満たす：
- 類似度は0から1の範囲内である
- 類似度は対称的である（similarity(A, B) == similarity(B, A)）
- 同一プロフィールの類似度は1である

**検証要件: 要件10.2**

#### プロパティ2: マッチング候補のソート順序

*任意の*マッチング候補リストに対して、ソート後のリストは適合度の降順になっている（各要素の適合度 >= 次の要素の適合度）

**検証要件: 要件10.3**

#### プロパティ3: 検索結果のソート順序

*任意の*検索クエリと結果セットに対して、返される結果は関連度の降順になっている（各要素の関連度スコア >= 次の要素の関連度スコア）

**検証要件: 要件18.2**

#### プロパティ4: 検索フィルタリングの正確性

*任意の*検索結果セットとフィルタ条件に対して、フィルタリング後のすべての結果は指定された条件を満たす

**検証要件: 要件18.5**

#### プロパティ5: パスワード暗号化の一方向性

*任意の*パスワード文字列に対して：
- 暗号化後の値は元の値と異なる
- 同じパスワードでも毎回異なるハッシュが生成される（ソルト使用）
- 暗号化されたパスワードから元のパスワードを復元できない

**検証要件: 要件1.5**

#### プロパティ6: 投稿文字数バリデーション

*任意の*文字列に対して：
- 文字数が3000以下の場合、バリデーションは成功する
- 文字数が3001以上の場合、バリデーションは失敗する

**検証要件: 要件8.4**

#### プロパティ7: パスワード強度バリデーション

*任意の*パスワード文字列に対して、以下の条件をすべて満たす場合のみバリデーションが成功する：
- 長さが8文字以上
- 英字（a-z, A-Z）を少なくとも1文字含む
- 数字（0-9）を少なくとも1文字含む
- 記号（@$!%*?&など）を少なくとも1文字含む

**検証要件: 要件15.6**

## エラーハンドリング

### エラー分類

#### 1. バリデーションエラー（400 Bad Request）

**発生条件:**
- 入力データが形式要件を満たさない
- 必須フィールドが欠落している
- データ型が不正

**処理:**
- 詳細なエラーメッセージを日本語で返す
- どのフィールドに問題があるか明示
- 修正方法を提案

**例:**
\`\`\`json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "入力内容に誤りがあります",
    "details": [
      {
        "field": "email",
        "message": "メールアドレスの形式が正しくありません",
        "suggestion": "example@domain.com の形式で入力してください"
      },
      {
        "field": "password",
        "message": "パスワードは8文字以上で、英数字と記号を含める必要があります"
      }
    ]
  }
}
\`\`\`

#### 2. 認証エラー（401 Unauthorized）

**発生条件:**
- 認証情報が不正または欠落
- セッションが期限切れ
- トークンが無効

**処理:**
- ログインページへリダイレクト
- セッション情報をクリア
- エラーメッセージを表示

**例:**
\`\`\`json
{
  "success": false,
  "error": {
    "code": "UNAUTHORIZED",
    "message": "認証が必要です。ログインしてください。",
    "redirect_url": "/login"
  }
}
\`\`\`

#### 3. 認可エラー（403 Forbidden）

**発生条件:**
- 権限が不足している
- リソースへのアクセスが禁止されている

**処理:**
- アクセス拒否メッセージを表示
- 適切な権限を持つユーザーに連絡する方法を提示

**例:**
\`\`\`json
{
  "success": false,
  "error": {
    "code": "FORBIDDEN",
    "message": "この操作を実行する権限がありません",
    "required_role": "admin"
  }
}
\`\`\`

#### 4. リソース未検出エラー（404 Not Found）

**発生条件:**
- 要求されたリソースが存在しない
- URLが不正

**処理:**
- 404ページを表示
- 関連するリソースへのリンクを提示
- 検索機能を提供

#### 5. サーバーエラー（500 Internal Server Error）

**発生条件:**
- 予期しない例外が発生
- データベース接続エラー
- 外部サービスエラー

**処理:**
- エラーをログに記録
- エラーIDを生成してユーザーに提示
- 管理者に通知
- ユーザーフレンドリーなエラーメッセージを表示

**例:**
\`\`\`json
{
  "success": false,
  "error": {
    "code": "INTERNAL_SERVER_ERROR",
    "message": "システムエラーが発生しました。しばらくしてから再度お試しください。",
    "error_id": "ERR-2024-01-15-12345",
    "support_email": "support@example.com"
  }
}
\`\`\`

### エラーハンドリング実装

#### Rails側（バックエンド）

\`\`\`ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::API
  include ErrorHandler

  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :handle_validation_error
  rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing
  rescue_from Pundit::NotAuthorizedError, with: :handle_unauthorized
  rescue_from StandardError, with: :handle_internal_error

  private

  def handle_not_found(exception)
    render json: {
      success: false,
      error: {
        code: 'NOT_FOUND',
        message: 'リソースが見つかりません',
        details: exception.message
      }
    }, status: :not_found
  end

  def handle_validation_error(exception)
    render json: {
      success: false,
      error: {
        code: 'VALIDATION_ERROR',
        message: '入力内容に誤りがあります',
        details: exception.record.errors.full_messages.map { |msg|
          { message: msg }
        }
      }
    }, status: :unprocessable_entity
  end

  def handle_parameter_missing(exception)
    render json: {
      success: false,
      error: {
        code: 'PARAMETER_MISSING',
        message: "必須パラメータが不足しています: #{exception.param}",
        param: exception.param
      }
    }, status: :bad_request
  end

  def handle_unauthorized(exception)
    render json: {
      success: false,
      error: {
        code: 'FORBIDDEN',
        message: 'この操作を実行する権限がありません',
        required_permission: exception.policy.class.name
      }
    }, status: :forbidden
  end

  def handle_internal_error(exception)
    error_id = SecureRandom.uuid
    Rails.logger.error("Error ID: #{error_id} - #{exception.class}: #{exception.message}")
    Rails.logger.error(exception.backtrace.join("\n"))

    # 管理者に通知
    ErrorNotificationService.notify_admin(error_id, exception)

    render json: {
      success: false,
      error: {
        code: 'INTERNAL_SERVER_ERROR',
        message: 'システムエラーが発生しました。しばらくしてから再度お試しください。',
        error_id: error_id,
        support_email: ENV['SUPPORT_EMAIL']
      }
    }, status: :internal_server_error
  end
end
\`\`\`

#### Next.js側（フロントエンド）

\`\`\`typescript
// lib/api/error-handler.ts
export class APIError extends Error {
  constructor(
    public code: string,
    public message: string,
    public status: number,
    public details?: any
  ) {
    super(message);
    this.name = 'APIError';
  }
}

export async function handleAPIResponse<T>(response: Response): Promise<T> {
  if (!response.ok) {
    const errorData = await response.json();
    
    throw new APIError(
      errorData.error.code,
      errorData.error.message,
      response.status,
      errorData.error.details
    );
  }

  const data = await response.json();
  return data.data;
}

// components/ErrorBoundary.tsx
'use client';

import { Component, ReactNode } from 'react';

interface Props {
  children: ReactNode;
  fallback?: (error: Error) => ReactNode;
}

interface State {
  hasError: boolean;
  error?: Error;
}

export class ErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: any) {
    console.error('Error caught by boundary:', error, errorInfo);
    // エラーログサービスに送信
  }

  render() {
    if (this.state.hasError) {
      if (this.props.fallback) {
        return this.props.fallback(this.state.error!);
      }

      return (
        <div className="flex items-center justify-center min-h-screen">
          <div className="text-center">
            <h1 className="text-2xl font-bold mb-4">
              エラーが発生しました
            </h1>
            <p className="text-gray-600 mb-4">
              申し訳ございません。予期しないエラーが発生しました。
            </p>
            <button
              onClick={() => window.location.reload()}
              className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
            >
              ページを再読み込み
            </button>
          </div>
        </div>
      );
    }

    return this.props.children;
  }
}

// hooks/useErrorHandler.ts
import { useCallback } from 'react';
import { toast } from 'sonner';
import { APIError } from '@/lib/api/error-handler';

export function useErrorHandler() {
  const handleError = useCallback((error: unknown) => {
    if (error instanceof APIError) {
      switch (error.code) {
        case 'VALIDATION_ERROR':
          toast.error(error.message, {
            description: error.details?.map((d: any) => d.message).join(', ')
          });
          break;
        
        case 'UNAUTHORIZED':
          toast.error('認証が必要です');
          window.location.href = '/login';
          break;
        
        case 'FORBIDDEN':
          toast.error('権限がありません');
          break;
        
        case 'NOT_FOUND':
          toast.error('リソースが見つかりません');
          break;
        
        default:
          toast.error('エラーが発生しました', {
            description: error.message
          });
      }
    } else if (error instanceof Error) {
      toast.error('予期しないエラーが発生しました', {
        description: error.message
      });
    } else {
      toast.error('不明なエラーが発生しました');
    }
  }, []);

  return { handleError };
}
\`\`\`

### ネットワークエラーハンドリング

\`\`\`typescript
// lib/api/client.ts
import { toast } from 'sonner';

export async function apiClient<T>(
  url: string,
  options?: RequestInit
): Promise<T> {
  try {
    const response = await fetch(url, {
      ...options,
      headers: {
        'Content-Type': 'application/json',
        ...options?.headers,
      },
    });

    return await handleAPIResponse<T>(response);
  } catch (error) {
    if (error instanceof TypeError && error.message === 'Failed to fetch') {
      toast.error('ネットワークエラー', {
        description: 'インターネット接続を確認してください',
        action: {
          label: '再試行',
          onClick: () => apiClient<T>(url, options),
        },
      });
    }
    throw error;
  }
}
\`\`\`

## テスト戦略

### テストピラミッド

\`\`\`
         /\
        /  \  E2E Tests (5%)
       /____\
      /      \  Integration Tests (15%)
     /________\
    /          \  Unit Tests (80%)
   /__________  \
\`\`\`

### 1. ユニットテスト（80%）

**対象:**
- ビジネスロジック（Services, Interactors）
- ユーティリティ関数
- バリデーション
- データ変換

**ツール:**
- Rails: RSpec
- Next.js: Jest + React Testing Library

**カバレッジ目標:** 80%以上

**例（Rails）:**
\`\`\`ruby
# spec/services/matching/similarity_calculator_spec.rb
RSpec.describe Matching::SimilarityCalculator do
  describe '#calculate' do
    it 'returns similarity between 0 and 1' do
      profile1 = create(:profile, interests: ['Ruby', 'Rails'])
      profile2 = create(:profile, interests: ['Ruby', 'Python'])
      
      similarity = described_class.new(profile1, profile2).calculate
      
      expect(similarity).to be_between(0, 1)
    end

    it 'returns 1 for identical profiles' do
      profile = create(:profile, interests: ['Ruby', 'Rails'])
      
      similarity = described_class.new(profile, profile).calculate
      
      expect(similarity).to eq(1.0)
    end

    it 'is symmetric' do
      profile1 = create(:profile, interests: ['Ruby'])
      profile2 = create(:profile, interests: ['Python'])
      
      similarity1 = described_class.new(profile1, profile2).calculate
      similarity2 = described_class.new(profile2, profile1).calculate
      
      expect(similarity1).to eq(similarity2)
    end
  end
end
\`\`\`

**例（Next.js）:**
\`\`\`typescript
// __tests__/components/PostCard.test.tsx
import { render, screen } from '@testing-library/react';
import { PostCard } from '@/components/organisms/PostCard';

describe('PostCard', () => {
  it('displays post content', () => {
    const post = {
      id: 1,
      content: 'テスト投稿',
      user: { name: 'テストユーザー' },
      likes_count: 5,
      comments_count: 3,
    };

    render(<PostCard post={post} />);

    expect(screen.getByText('テスト投稿')).toBeInTheDocument();
    expect(screen.getByText('テストユーザー')).toBeInTheDocument();
  });

  it('shows like count', () => {
    const post = {
      id: 1,
      content: 'テスト',
      likes_count: 10,
    };

    render(<PostCard post={post} />);

    expect(screen.getByText('10')).toBeInTheDocument();
  });
});
\`\`\`

### 2. プロパティベーステスト

**対象:**
- マッチングアルゴリズム
- 検索機能
- バリデーションロジック
- データ変換

**ツール:**
- Rails: RSpec + rspec-propcheck
- Next.js: fast-check

**実行回数:** 最低100回/プロパティ

**例（Rails）:**
\`\`\`ruby
# spec/services/matching/similarity_calculator_property_spec.rb
require 'rspec/propcheck'

RSpec.describe Matching::SimilarityCalculator do
  include RSpec::Propcheck

  # Feature: business-efficiency-platform, Property 1: マッチング類似度の対称性と範囲
  property 'similarity is symmetric and within range' do
    forall(
      profile1: profile_generator,
      profile2: profile_generator
    ) do |profile1, profile2|
      calculator = described_class.new(profile1, profile2)
      similarity = calculator.calculate

      # 範囲チェック
      expect(similarity).to be_between(0, 1).inclusive

      # 対称性チェック
      reverse_similarity = described_class.new(profile2, profile1).calculate
      expect(similarity).to eq(reverse_similarity)
    end
  end

  # Feature: business-efficiency-platform, Property 1: マッチング類似度の対称性と範囲
  property 'identical profiles have similarity of 1' do
    forall(profile: profile_generator) do |profile|
      similarity = described_class.new(profile, profile).calculate
      expect(similarity).to eq(1.0)
    end
  end

  def profile_generator
    Propcheck::Generators.hash(
      interests: Propcheck::Generators.array(Propcheck::Generators.string, min: 0, max: 10),
      skills: Propcheck::Generators.array(Propcheck::Generators.string, min: 0, max: 10)
    )
  end
end
\`\`\`

**例（Next.js）:**
\`\`\`typescript
// __tests__/lib/validation/password.property.test.ts
import fc from 'fast-check';
import { validatePassword } from '@/lib/validation/password';

describe('Password Validation Properties', () => {
  // Feature: business-efficiency-platform, Property 7: パスワード強度バリデーション
  it('accepts passwords with 8+ chars, letters, numbers, and symbols', () => {
    fc.assert(
      fc.property(
        fc.string({ minLength: 8, maxLength: 20 })
          .filter(s => /[a-zA-Z]/.test(s))
          .filter(s => /\d/.test(s))
          .filter(s => /[@$!%*?&]/.test(s)),
        (password) => {
          const result = validatePassword(password);
          expect(result.valid).toBe(true);
        }
      ),
      { numRuns: 100 }
    );
  });

  // Feature: business-efficiency-platform, Property 7: パスワード強度バリデーション
  it('rejects passwords shorter than 8 characters', () => {
    fc.assert(
      fc.property(
        fc.string({ maxLength: 7 }),
        (password) => {
          const result = validatePassword(password);
          expect(result.valid).toBe(false);
        }
      ),
      { numRuns: 100 }
    );
  });
});
\`\`\`

### 3. 統合テスト（15%）

**対象:**
- API エンドポイント
- データベース操作
- 外部サービス連携（モック使用）
- モジュール間連携

**ツール:**
- Rails: RSpec + FactoryBot
- Next.js: Playwright

**例（Rails API）:**
\`\`\`ruby
# spec/requests/api/v1/posts_spec.rb
RSpec.describe 'API::V1::Posts', type: :request do
  let(:user) { create(:user) }
  let(:headers) { { 'Authorization' => "Bearer #{user.auth_token}" } }

  describe 'POST /api/v1/posts' do
    context 'with valid parameters' do
      let(:valid_params) do
        { post: { content: 'テスト投稿' } }
      end

      it 'creates a new post' do
        expect {
          post '/api/v1/posts', params: valid_params, headers: headers
        }.to change(Post, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json_response['data']['content']).to eq('テスト投稿')
      end
    end

    context 'with content exceeding 3000 characters' do
      let(:invalid_params) do
        { post: { content: 'a' * 3001 } }
      end

      it 'returns validation error' do
        post '/api/v1/posts', params: invalid_params, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['error']['code']).to eq('VALIDATION_ERROR')
      end
    end
  end
end
\`\`\`

### 4. E2Eテスト（5%）

**対象:**
- クリティカルユーザーフロー
- 主要機能の動作確認

**ツール:**
- Playwright

**例:**
\`\`\`typescript
// e2e/user-registration.spec.ts
import { test, expect } from '@playwright/test';

test.describe('ユーザー登録フロー', () => {
  test('新規ユーザーが登録できる', async ({ page }) => {
    await page.goto('/register');

    // フォーム入力
    await page.fill('input[name="email"]', 'test@example.com');
    await page.fill('input[name="password"]', 'Test123!@#');
    await page.fill('input[name="password_confirmation"]', 'Test123!@#');

    // 登録ボタンクリック
    await page.click('button[type="submit"]');

    // 成功メッセージ確認
    await expect(page.locator('text=確認メールを送信しました')).toBeVisible();
  });

  test('無効なパスワードでエラーが表示される', async ({ page }) => {
    await page.goto('/register');

    await page.fill('input[name="email"]', 'test@example.com');
    await page.fill('input[name="password"]', 'weak');
    await page.click('button[type="submit"]');

    await expect(
      page.locator('text=パスワードは8文字以上で、英数字と記号を含める必要があります')
    ).toBeVisible();
  });
});
\`\`\`

### CI/CD統合

\`\`\`yaml
# .github/workflows/test.yml
name: Test Suite

on: [push, pull_request]

jobs:
  backend-tests:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: 3.2
          bundler-cache: true

      - name: Run RSpec
        run: |
          bundle exec rspec --format documentation
          
      - name: Upload coverage
        uses: codecov/codecov-action@v3

  frontend-tests:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '20'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run Jest
        run: npm run test:coverage

      - name: Run Playwright
        run: npx playwright test

      - name: Upload coverage
        uses: codecov/codecov-action@v3
\`\`\`

### テスト実行コマンド

**Rails:**
\`\`\`bash
# すべてのテスト
bundle exec rspec

# ユニットテストのみ
bundle exec rspec spec/models spec/services

# プロパティテストのみ
bundle exec rspec spec/**/*_property_spec.rb

# 統合テストのみ
bundle exec rspec spec/requests

# カバレッジレポート生成
COVERAGE=true bundle exec rspec
\`\`\`

**Next.js:**
\`\`\`bash
# すべてのテスト
npm run test

# ユニットテストのみ
npm run test:unit

# プロパティテストのみ
npm run test:property

# E2Eテスト
npm run test:e2e

# カバレッジレポート
npm run test:coverage
\`\`\`


## セキュリティ設計

### 認証・認可

#### 認証方式

**セッションベース認証（Web）:**
- Rails の Devise gem を使用
- HTTPOnly Cookie でセッショントークンを管理
- CSRF トークンによる保護

**JWTトークン認証（API/モバイル）:**
- アクセストークン（短期間有効: 15分）
- リフレッシュトークン（長期間有効: 7日）
- トークンローテーション実装

\`\`\`ruby
# app/services/authentication_service.rb
class AuthenticationService
  def self.generate_tokens(user)
    access_token = JWT.encode(
      {
        user_id: user.id,
        exp: 15.minutes.from_now.to_i,
        type: 'access'
      },
      Rails.application.credentials.secret_key_base,
      'HS256'
    )

    refresh_token = JWT.encode(
      {
        user_id: user.id,
        exp: 7.days.from_now.to_i,
        type: 'refresh',
        jti: SecureRandom.uuid
      },
      Rails.application.credentials.secret_key_base,
      'HS256'
    )

    # リフレッシュトークンをRedisに保存
    Redis.current.setex(
      "refresh_token:#{user.id}:#{refresh_token}",
      7.days.to_i,
      true
    )

    { access_token: access_token, refresh_token: refresh_token }
  end

  def self.verify_token(token, type: 'access')
    payload = JWT.decode(
      token,
      Rails.application.credentials.secret_key_base,
      true,
      { algorithm: 'HS256' }
    ).first

    return nil unless payload['type'] == type

    # リフレッシュトークンの場合、Redisで有効性確認
    if type == 'refresh'
      key = "refresh_token:#{payload['user_id']}:#{token}"
      return nil unless Redis.current.exists?(key)
    end

    User.find(payload['user_id'])
  rescue JWT::DecodeError, JWT::ExpiredSignature
    nil
  end
end
\`\`\`

#### 認可（Authorization）

**Pundit を使用したポリシーベース認可:**

\`\`\`ruby
# app/policies/post_policy.rb
class PostPolicy < ApplicationPolicy
  def index?
    true # 誰でも投稿一覧を閲覧可能
  end

  def show?
    true # 誰でも投稿詳細を閲覧可能
  end

  def create?
    user.present? # ログインユーザーのみ投稿可能
  end

  def update?
    user.present? && (record.user_id == user.id || user.admin?)
  end

  def destroy?
    user.present? && (record.user_id == user.id || user.admin?)
  end

  class Scope < Scope
    def resolve
      if user&.admin?
        scope.all
      else
        scope.where(status: :published)
      end
    end
  end
end

# app/controllers/api/v1/posts_controller.rb
class API::V1::PostsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_post, only: [:show, :update, :destroy]

  def update
    authorize @post
    
    if @post.update(post_params)
      render json: { success: true, data: @post }
    else
      render json: { success: false, error: @post.errors }, 
             status: :unprocessable_entity
    end
  end
end
\`\`\`

### データ保護

#### 暗号化

**保存時の暗号化:**
\`\`\`ruby
# config/initializers/encryption.rb
Rails.application.config.active_record.encryption.primary_key = 
  Rails.application.credentials.active_record_encryption[:primary_key]
Rails.application.config.active_record.encryption.deterministic_key = 
  Rails.application.credentials.active_record_encryption[:deterministic_key]
Rails.application.config.active_record.encryption.key_derivation_salt = 
  Rails.application.credentials.active_record_encryption[:key_derivation_salt]

# app/models/user.rb
class User < ApplicationRecord
  encrypts :email, deterministic: true
  encrypts :phone_number
end
\`\`\`

**通信時の暗号化:**
- すべての通信をHTTPS/TLS 1.3で暗号化
- HSTS（HTTP Strict Transport Security）有効化
- 証明書の自動更新（Let's Encrypt）

\`\`\`ruby
# config/environments/production.rb
config.force_ssl = true
config.ssl_options = {
  hsts: {
    expires: 1.year,
    subdomains: true,
    preload: true
  }
}
\`\`\`

#### パスワードセキュリティ

\`\`\`ruby
# Devise設定
Devise.setup do |config|
  # bcryptのストレッチ回数（計算コスト）
  config.stretches = Rails.env.test? ? 1 : 12

  # パスワード複雑性要件
  config.password_length = 8..128
  
  # カスタムバリデーター
  config.password_complexity = {
    digit: 1,
    lower: 1,
    symbol: 1,
    upper: 0
  }
end

# app/validators/password_complexity_validator.rb
class PasswordComplexityValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    unless value.match?(/(?=.*[a-zA-Z])(?=.*\d)(?=.*[@$!%*?&])/)
      record.errors.add(
        attribute,
        'は英数字と記号(@$!%*?&)を含める必要があります'
      )
    end
  end
end
\`\`\`

### 脆弱性対策

#### OWASP Top 10 対策

**1. インジェクション対策:**
\`\`\`ruby
# SQLインジェクション対策（パラメータ化クエリ）
# 悪い例
User.where("email = '#{params[:email]}'") # ❌

# 良い例
User.where(email: params[:email]) # ✅
User.where('email = ?', params[:email]) # ✅

# XSS対策（自動エスケープ）
# ERBテンプレートは自動的にエスケープ
<%= @user.name %> # 自動エスケープ ✅
<%== @user.name %> # エスケープなし ❌（意図的な場合のみ）
\`\`\`

**2. 認証の不備対策:**
\`\`\`ruby
# セッションタイムアウト
Devise.setup do |config|
  config.timeout_in = 30.minutes
end

# アカウントロックアウト（ブルートフォース対策）
Devise.setup do |config|
  config.lock_strategy = :failed_attempts
  config.unlock_strategy = :time
  config.maximum_attempts = 5
  config.unlock_in = 1.hour
end
\`\`\`

**3. 機密データの露出対策:**
\`\`\`ruby
# app/serializers/user_serializer.rb
class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :display_name, :avatar_url
  
  # パスワードハッシュなどの機密情報は含めない
end

# Strong Parameters
def user_params
  params.require(:user).permit(:email, :password, :password_confirmation)
end
\`\`\`

**4. XML外部エンティティ（XXE）対策:**
\`\`\`ruby
# config/application.rb
config.middleware.delete ActionDispatch::XmlParamsParser
\`\`\`

**5. アクセス制御の不備対策:**
\`\`\`ruby
# すべてのコントローラーアクションで認可チェック
class ApplicationController < ActionController::API
  include Pundit

  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    render json: {
      success: false,
      error: {
        code: 'FORBIDDEN',
        message: 'この操作を実行する権限がありません'
      }
    }, status: :forbidden
  end
end
\`\`\`

**6. セキュリティ設定のミス対策:**
\`\`\`ruby
# config/initializers/security_headers.rb
Rails.application.config.action_dispatch.default_headers = {
  'X-Frame-Options' => 'SAMEORIGIN',
  'X-Content-Type-Options' => 'nosniff',
  'X-XSS-Protection' => '1; mode=block',
  'Referrer-Policy' => 'strict-origin-when-cross-origin',
  'Permissions-Policy' => 'geolocation=(), microphone=(), camera=()'
}
\`\`\`

**7. クロスサイトスクリプティング（XSS）対策:**
\`\`\`typescript
// Next.js側でのサニタイゼーション
import DOMPurify from 'isomorphic-dompurify';

export function sanitizeHTML(dirty: string): string {
  return DOMPurify.sanitize(dirty, {
    ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'a', 'p', 'br'],
    ALLOWED_ATTR: ['href', 'target']
  });
}

// 使用例
<div dangerouslySetInnerHTML={{ __html: sanitizeHTML(content) }} />
\`\`\`

**8. 安全でないデシリアライゼーション対策:**
\`\`\`ruby
# JSONのみを使用、Marshalは使用しない
# 悪い例
Marshal.load(params[:data]) # ❌

# 良い例
JSON.parse(params[:data]) # ✅
\`\`\`

**9. 既知の脆弱性を持つコンポーネント対策:**
\`\`\`bash
# 定期的な依存関係の更新
bundle audit check --update
npm audit fix

# Dependabot有効化（GitHub）
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "bundler"
    directory: "/"
    schedule:
      interval: "weekly"
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
\`\`\`

**10. ログとモニタリングの不足対策:**
\`\`\`ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::API
  before_action :log_request
  after_action :log_response

  private

  def log_request
    Rails.logger.info({
      type: 'request',
      method: request.method,
      path: request.path,
      user_id: current_user&.id,
      ip: request.remote_ip,
      user_agent: request.user_agent,
      timestamp: Time.current
    }.to_json)
  end

  def log_response
    Rails.logger.info({
      type: 'response',
      status: response.status,
      user_id: current_user&.id,
      timestamp: Time.current
    }.to_json)
  end
end
\`\`\`

#### CSRF対策

\`\`\`ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::API
  include ActionController::RequestForgeryProtection
  
  protect_from_forgery with: :exception, unless: :json_request?

  private

  def json_request?
    request.format.json?
  end
end
\`\`\`

\`\`\`typescript
// Next.js側でのCSRFトークン処理
// lib/api/csrf.ts
export async function getCSRFToken(): Promise<string> {
  const response = await fetch('/api/csrf-token');
  const data = await response.json();
  return data.token;
}

export async function apiClientWithCSRF<T>(
  url: string,
  options?: RequestInit
): Promise<T> {
  const token = await getCSRFToken();
  
  return apiClient<T>(url, {
    ...options,
    headers: {
      ...options?.headers,
      'X-CSRF-Token': token,
    },
  });
}
\`\`\`

#### レート制限

\`\`\`ruby
# Gemfile
gem 'rack-attack'

# config/initializers/rack_attack.rb
class Rack::Attack
  # IPアドレスごとのリクエスト制限
  throttle('req/ip', limit: 300, period: 5.minutes) do |req|
    req.ip
  end

  # ログインエンドポイントの制限（ブルートフォース対策）
  throttle('logins/ip', limit: 5, period: 20.seconds) do |req|
    if req.path == '/api/v1/auth/login' && req.post?
      req.ip
    end
  end

  # ユーザーごとのAPI制限
  throttle('api/user', limit: 1000, period: 1.hour) do |req|
    req.env['warden']&.user&.id if req.path.start_with?('/api/')
  end

  # ブロックされた場合のレスポンス
  self.throttled_responder = lambda do |env|
    [
      429,
      { 'Content-Type' => 'application/json' },
      [{
        success: false,
        error: {
          code: 'RATE_LIMIT_EXCEEDED',
          message: 'リクエスト制限を超えました。しばらくしてから再度お試しください。'
        }
      }.to_json]
    ]
  end
end
\`\`\`

### セキュリティ監査

\`\`\`bash
# 定期的なセキュリティチェック
bundle audit check
npm audit
brakeman -A -q # Railsセキュリティスキャナー

# 本番環境デプロイ前のチェックリスト
- [ ] すべての依存関係が最新
- [ ] 既知の脆弱性がない
- [ ] 環境変数が適切に設定
- [ ] HTTPS強制が有効
- [ ] セキュリティヘッダーが設定
- [ ] レート制限が有効
- [ ] ログが適切に記録
- [ ] バックアップが設定
\`\`\`

## パフォーマンス最適化

### フロントエンド最適化

#### 1. Next.js最適化

**画像最適化:**
\`\`\`typescript
// next.config.js
module.exports = {
  images: {
    domains: ['your-cdn-domain.com'],
    formats: ['image/avif', 'image/webp'],
    deviceSizes: [640, 750, 828, 1080, 1200, 1920, 2048, 3840],
    imageSizes: [16, 32, 48, 64, 96, 128, 256, 384],
  },
};

// 使用例
import Image from 'next/image';

<Image
  src="/avatar.jpg"
  alt="ユーザーアバター"
  width={100}
  height={100}
  loading="lazy"
  placeholder="blur"
/>
\`\`\`

**コード分割:**
\`\`\`typescript
// 動的インポート
import dynamic from 'next/dynamic';

const HeavyComponent = dynamic(() => import('@/components/HeavyComponent'), {
  loading: () => <div>読み込み中...</div>,
  ssr: false, // クライアントサイドのみでレンダリング
});

// ルートベースのコード分割は自動的に行われる
\`\`\`

**フォント最適化:**
\`\`\`typescript
// app/layout.tsx
import { Noto_Sans_JP } from 'next/font/google';

const notoSansJP = Noto_Sans_JP({
  weight: ['400', '500', '700'],
  subsets: ['latin'],
  display: 'swap',
  preload: true,
});

export default function RootLayout({ children }: { children: React.Node }) {
  return (
    <html lang="ja" className={notoSansJP.className}>
      <body>{children}</body>
    </html>
  );
}
\`\`\`

#### 2. キャッシング戦略

**TanStack Query設定:**
\`\`\`typescript
// lib/query-client.ts
import { QueryClient } from '@tanstack/react-query';

export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 5 * 60 * 1000, // 5分
      cacheTime: 10 * 60 * 1000, // 10分
      refetchOnWindowFocus: false,
      retry: 1,
    },
  },
});

// 使用例
function usePost(id: string) {
  return useQuery({
    queryKey: ['post', id],
    queryFn: () => fetchPost(id),
    staleTime: 10 * 60 * 1000, // この投稿は10分間キャッシュ
  });
}
\`\`\`

**Service Worker（PWA）:**
\`\`\`typescript
// next.config.js
const withPWA = require('next-pwa')({
  dest: 'public',
  register: true,
  skipWaiting: true,
  disable: process.env.NODE_ENV === 'development',
});

module.exports = withPWA({
  // Next.js config
});
\`\`\`

#### 3. バンドルサイズ最適化

\`\`\`typescript
// next.config.js
module.exports = {
  webpack: (config, { isServer }) => {
    if (!isServer) {
      // クライアントバンドルから不要なモジュールを除外
      config.resolve.fallback = {
        fs: false,
        net: false,
        tls: false,
      };
    }

    // Bundle Analyzer（開発時のみ）
    if (process.env.ANALYZE === 'true') {
      const { BundleAnalyzerPlugin } = require('webpack-bundle-analyzer');
      config.plugins.push(
        new BundleAnalyzerPlugin({
          analyzerMode: 'static',
          openAnalyzer: true,
        })
      );
    }

    return config;
  },
};
\`\`\`

### バックエンド最適化

#### 1. データベースクエリ最適化

**N+1問題の解決:**
\`\`\`ruby
# 悪い例（N+1問題）
posts = Post.all
posts.each do |post|
  puts post.user.name # 各投稿ごとにクエリ実行
end

# 良い例（Eager Loading）
posts = Post.includes(:user).all
posts.each do |post|
  puts post.user.name # 1回のクエリで取得
end

# さらに複雑な関連
posts = Post.includes(:user, :comments, comments: :user).all
\`\`\`

**カウンターキャッシュ:**
\`\`\`ruby
# app/models/post.rb
class Post < ApplicationRecord
  belongs_to :user, counter_cache: true
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
end

# マイグレーション
add_column :users, :posts_count, :integer, default: 0, null: false
add_column :posts, :comments_count, :integer, default: 0, null: false
add_column :posts, :likes_count, :integer, default: 0, null: false

# 既存データの更新
User.find_each { |u| User.reset_counters(u.id, :posts) }
\`\`\`

**データベースインデックス:**
\`\`\`ruby
# 複合インデックス
add_index :posts, [:user_id, :created_at]
add_index :posts, [:status, :published_at]

# 部分インデックス（PostgreSQL）
add_index :posts, :user_id, where: "status = 'published'"

# 全文検索インデックス
enable_extension 'pg_trgm'
add_index :posts, :content, using: :gin, opclass: :gin_trgm_ops
\`\`\`

#### 2. キャッシング

**Redisキャッシング:**
\`\`\`ruby
# config/environments/production.rb
config.cache_store = :redis_cache_store, {
  url: ENV['REDIS_URL'],
  expires_in: 1.hour,
  namespace: 'cache'
}

# 使用例
class PostsController < ApplicationController
  def index
    @posts = Rails.cache.fetch('posts/recent', expires_in: 5.minutes) do
      Post.includes(:user).recent.limit(20).to_a
    end
    
    render json: @posts
  end
end

# フラグメントキャッシング
class Post < ApplicationRecord
  after_save :clear_cache
  after_destroy :clear_cache

  private

  def clear_cache
    Rails.cache.delete('posts/recent')
  end
end
\`\`\`

**HTTPキャッシング:**
\`\`\`ruby
class API::V1::PostsController < ApplicationController
  def show
    @post = Post.find(params[:id])
    
    # ETag
    if stale?(etag: @post, last_modified: @post.updated_at)
      render json: @post
    end
  end

  def index
    @posts = Post.recent.limit(20)
    
    # Cache-Control
    expires_in 5.minutes, public: true
    render json: @posts
  end
end
\`\`\`

#### 3. バックグラウンドジョブ

\`\`\`ruby
# app/jobs/send_notification_job.rb
class SendNotificationJob < ApplicationJob
  queue_as :default

  def perform(user_id, notification_type, data)
    user = User.find(user_id)
    NotificationService.send_notification(user, notification_type, data)
  end
end

# 使用例
SendNotificationJob.perform_later(user.id, 'new_match', { match_id: match.id })

# 優先度付きキュー
class UrgentNotificationJob < ApplicationJob
  queue_as :urgent
  
  def perform(user_id, message)
    # 緊急通知処理
  end
end
\`\`\`

#### 4. データベース接続プール

\`\`\`ruby
# config/database.yml
production:
  adapter: postgresql
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  timeout: 5000
  # 接続プールの最適化
  checkout_timeout: 5
  reaping_frequency: 10
  pool: 25
\`\`\`

### CDN設定

\`\`\`typescript
// next.config.js
module.exports = {
  assetPrefix: process.env.NODE_ENV === 'production' 
    ? 'https://cdn.your-domain.com' 
    : '',
  
  async headers() {
    return [
      {
        source: '/:all*(svg|jpg|png|webp|avif)',
        headers: [
          {
            key: 'Cache-Control',
            value: 'public, max-age=31536000, immutable',
          },
        ],
      },
    ];
  },
};
\`\`\`

### パフォーマンスモニタリング

\`\`\`ruby
# Gemfile
gem 'skylight' # APMツール

# config/initializers/skylight.rb
Skylight.start!(
  authentication: ENV['SKYLIGHT_AUTHENTICATION']
)

# カスタムインストルメンテーション
ActiveSupport::Notifications.instrument('matching.calculate_similarity') do
  # 処理
end
\`\`\`

\`\`\`typescript
// Next.js Web Vitals
// app/layout.tsx
export function reportWebVitals(metric: NextWebVitalsMetric) {
  // Analytics サービスに送信
  if (metric.label === 'web-vital') {
    console.log(metric);
    // 例: Google Analytics
    gtag('event', metric.name, {
      value: Math.round(metric.value),
      event_label: metric.id,
      non_interaction: true,
    });
  }
}
\`\`\`


## UI/UXデザイン

### デザインシステム

#### カラーパレット

\`\`\`typescript
// tailwind.config.ts
export default {
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#f0f9ff',
          100: '#e0f2fe',
          200: '#bae6fd',
          300: '#7dd3fc',
          400: '#38bdf8',
          500: '#0ea5e9', // メインカラー
          600: '#0284c7',
          700: '#0369a1',
          800: '#075985',
          900: '#0c4a6e',
        },
        secondary: {
          50: '#faf5ff',
          100: '#f3e8ff',
          200: '#e9d5ff',
          300: '#d8b4fe',
          400: '#c084fc',
          500: '#a855f7',
          600: '#9333ea',
          700: '#7e22ce',
          800: '#6b21a8',
          900: '#581c87',
        },
        success: '#10b981',
        warning: '#f59e0b',
        error: '#ef4444',
        info: '#3b82f6',
      },
    },
  },
};
\`\`\`

#### タイポグラフィ

\`\`\`typescript
// tailwind.config.ts
export default {
  theme: {
    extend: {
      fontSize: {
        'xs': ['0.75rem', { lineHeight: '1rem' }],
        'sm': ['0.875rem', { lineHeight: '1.25rem' }],
        'base': ['1rem', { lineHeight: '1.5rem' }],
        'lg': ['1.125rem', { lineHeight: '1.75rem' }],
        'xl': ['1.25rem', { lineHeight: '1.75rem' }],
        '2xl': ['1.5rem', { lineHeight: '2rem' }],
        '3xl': ['1.875rem', { lineHeight: '2.25rem' }],
        '4xl': ['2.25rem', { lineHeight: '2.5rem' }],
      },
      fontFamily: {
        sans: ['Noto Sans JP', 'sans-serif'],
      },
    },
  },
};
\`\`\`

#### スペーシング

\`\`\`typescript
// 8pxグリッドシステム
const spacing = {
  0: '0',
  1: '0.25rem',  // 4px
  2: '0.5rem',   // 8px
  3: '0.75rem',  // 12px
  4: '1rem',     // 16px
  5: '1.25rem',  // 20px
  6: '1.5rem',   // 24px
  8: '2rem',     // 32px
  10: '2.5rem',  // 40px
  12: '3rem',    // 48px
  16: '4rem',    // 64px
  20: '5rem',    // 80px
};
\`\`\`

### コンポーネントライブラリ

#### ボタンコンポーネント

\`\`\`typescript
// components/atoms/Button/Button.tsx
import { cva, type VariantProps } from 'class-variance-authority';
import { ButtonHTMLAttributes, forwardRef } from 'react';

const buttonVariants = cva(
  'inline-flex items-center justify-center rounded-md font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50',
  {
    variants: {
      variant: {
        primary: 'bg-primary-600 text-white hover:bg-primary-700',
        secondary: 'bg-secondary-600 text-white hover:bg-secondary-700',
        outline: 'border-2 border-primary-600 text-primary-600 hover:bg-primary-50',
        ghost: 'text-primary-600 hover:bg-primary-50',
        danger: 'bg-error text-white hover:bg-red-600',
      },
      size: {
        sm: 'h-9 px-3 text-sm',
        md: 'h-10 px-4 text-base',
        lg: 'h-11 px-6 text-lg',
      },
    },
    defaultVariants: {
      variant: 'primary',
      size: 'md',
    },
  }
);

export interface ButtonProps
  extends ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  loading?: boolean;
}

export const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, loading, children, disabled, ...props }, ref) => {
    return (
      <button
        ref={ref}
        className={buttonVariants({ variant, size, className })}
        disabled={disabled || loading}
        {...props}
      >
        {loading && (
          <svg
            className="mr-2 h-4 w-4 animate-spin"
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
          >
            <circle
              className="opacity-25"
              cx="12"
              cy="12"
              r="10"
              stroke="currentColor"
              strokeWidth="4"
            />
            <path
              className="opacity-75"
              fill="currentColor"
              d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
            />
          </svg>
        )}
        {children}
      </button>
    );
  }
);

Button.displayName = 'Button';
\`\`\`

#### フォームコンポーネント

\`\`\`typescript
// components/molecules/FormField/FormField.tsx
import { InputHTMLAttributes, forwardRef } from 'react';
import { Label } from '@/components/atoms/Label';
import { Input } from '@/components/atoms/Input';

export interface FormFieldProps extends InputHTMLAttributes<HTMLInputElement> {
  label: string;
  error?: string;
  helperText?: string;
}

export const FormField = forwardRef<HTMLInputElement, FormFieldProps>(
  ({ label, error, helperText, id, ...props }, ref) => {
    const inputId = id || `field-${label.toLowerCase().replace(/\s+/g, '-')}`;

    return (
      <div className="space-y-2">
        <Label htmlFor={inputId}>{label}</Label>
        <Input
          ref={ref}
          id={inputId}
          aria-invalid={!!error}
          aria-describedby={error ? `${inputId}-error` : undefined}
          {...props}
        />
        {error && (
          <p id={`${inputId}-error`} className="text-sm text-error" role="alert">
            {error}
          </p>
        )}
        {helperText && !error && (
          <p className="text-sm text-gray-500">{helperText}</p>
        )}
      </div>
    );
  }
);

FormField.displayName = 'FormField';
\`\`\`

### レスポンシブデザイン

#### ブレークポイント

\`\`\`typescript
// tailwind.config.ts
export default {
  theme: {
    screens: {
      'sm': '640px',   // スマートフォン（縦）
      'md': '768px',   // タブレット（縦）
      'lg': '1024px',  // タブレット（横）・小型ノートPC
      'xl': '1280px',  // デスクトップ
      '2xl': '1536px', // 大型デスクトップ
    },
  },
};
\`\`\`

#### レスポンシブレイアウト例

\`\`\`typescript
// components/templates/MainLayout/MainLayout.tsx
export function MainLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="min-h-screen bg-gray-50">
      {/* ヘッダー */}
      <header className="sticky top-0 z-50 bg-white border-b">
        <div className="container mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-16">
            <Logo />
            <Navigation />
            <UserMenu />
          </div>
        </div>
      </header>

      {/* メインコンテンツ */}
      <div className="container mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
          {/* サイドバー（デスクトップのみ） */}
          <aside className="hidden lg:block lg:col-span-3">
            <Sidebar />
          </aside>

          {/* メインエリア */}
          <main className="lg:col-span-9">
            {children}
          </main>
        </div>
      </div>

      {/* フッター */}
      <footer className="bg-white border-t mt-auto">
        <div className="container mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <Footer />
        </div>
      </footer>
    </div>
  );
}
\`\`\`

### アクセシビリティ

#### ARIA属性の使用

\`\`\`typescript
// components/organisms/Timeline/Timeline.tsx
export function Timeline({ posts }: { posts: Post[] }) {
  return (
    <div
      role="feed"
      aria-label="タイムライン"
      aria-busy={isLoading}
    >
      {posts.map((post, index) => (
        <article
          key={post.id}
          role="article"
          aria-posinset={index + 1}
          aria-setsize={posts.length}
          aria-labelledby={`post-${post.id}-author`}
        >
          <PostCard post={post} />
        </article>
      ))}
    </div>
  );
}
\`\`\`

#### キーボードナビゲーション

\`\`\`typescript
// components/organisms/Dropdown/Dropdown.tsx
export function Dropdown({ items }: { items: MenuItem[] }) {
  const [isOpen, setIsOpen] = useState(false);
  const [focusedIndex, setFocusedIndex] = useState(0);

  const handleKeyDown = (e: KeyboardEvent) => {
    switch (e.key) {
      case 'ArrowDown':
        e.preventDefault();
        setFocusedIndex((prev) => (prev + 1) % items.length);
        break;
      case 'ArrowUp':
        e.preventDefault();
        setFocusedIndex((prev) => (prev - 1 + items.length) % items.length);
        break;
      case 'Enter':
      case ' ':
        e.preventDefault();
        items[focusedIndex].onClick();
        setIsOpen(false);
        break;
      case 'Escape':
        setIsOpen(false);
        break;
    }
  };

  return (
    <div onKeyDown={handleKeyDown}>
      {/* ドロップダウン実装 */}
    </div>
  );
}
\`\`\`

#### スクリーンリーダー対応

\`\`\`typescript
// components/atoms/VisuallyHidden/VisuallyHidden.tsx
export function VisuallyHidden({ children }: { children: React.ReactNode }) {
  return (
    <span className="sr-only">
      {children}
    </span>
  );
}

// 使用例
<button>
  <HeartIcon />
  <VisuallyHidden>いいね</VisuallyHidden>
</button>
\`\`\`

### アニメーション

\`\`\`typescript
// tailwind.config.ts
export default {
  theme: {
    extend: {
      animation: {
        'fade-in': 'fadeIn 0.3s ease-in-out',
        'slide-in': 'slideIn 0.3s ease-out',
        'spin-slow': 'spin 3s linear infinite',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        slideIn: {
          '0%': { transform: 'translateY(-10px)', opacity: '0' },
          '100%': { transform: 'translateY(0)', opacity: '1' },
        },
      },
    },
  },
};

// 使用例
<div className="animate-fade-in">
  コンテンツ
</div>
\`\`\`

## デプロイメント

### 開発環境

\`\`\`yaml
# docker-compose.yml
version: '3.8'

services:
  db:
    image: postgres:15
    environment:
      POSTGRES_PASSWORD: postgres
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile.dev
    command: bundle exec rails server -b 0.0.0.0
    volumes:
      - ./backend:/app
      - bundle_cache:/usr/local/bundle
    ports:
      - "3000:3000"
    depends_on:
      - db
      - redis
    environment:
      DATABASE_URL: postgresql://postgres:postgres@db:5432/app_development
      REDIS_URL: redis://redis:6379/0

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile.dev
    command: npm run dev
    volumes:
      - ./frontend:/app
      - node_modules:/app/node_modules
    ports:
      - "3001:3000"
    depends_on:
      - backend
    environment:
      NEXT_PUBLIC_API_URL: http://localhost:3000

  sidekiq:
    build:
      context: ./backend
      dockerfile: Dockerfile.dev
    command: bundle exec sidekiq
    volumes:
      - ./backend:/app
    depends_on:
      - db
      - redis
    environment:
      DATABASE_URL: postgresql://postgres:postgres@db:5432/app_development
      REDIS_URL: redis://redis:6379/0

volumes:
  postgres_data:
  bundle_cache:
  node_modules:
\`\`\`

### 本番環境（AWS）

#### インフラ構成図

\`\`\`mermaid
graph TB
    subgraph "AWS Cloud"
        subgraph "VPC"
            subgraph "Public Subnet"
                ALB[Application Load Balancer]
                NAT[NAT Gateway]
            end
            
            subgraph "Private Subnet"
                ECS1[ECS Task<br/>Rails API]
                ECS2[ECS Task<br/>Next.js]
                ECS3[ECS Task<br/>Sidekiq]
            end
            
            subgraph "Data Layer"
                RDS[(RDS PostgreSQL<br/>Multi-AZ)]
                ElastiCache[(ElastiCache Redis<br/>Cluster)]
            end
        end
        
        CloudFront[CloudFront CDN]
        S3[S3 Bucket<br/>Static Assets]
        SES[SES<br/>Email Service]
        CloudWatch[CloudWatch<br/>Logs & Metrics]
    end
    
    Internet[インターネット]
    
    Internet --> CloudFront
    CloudFront --> ALB
    CloudFront --> S3
    ALB --> ECS1
    ALB --> ECS2
    ECS1 --> RDS
    ECS1 --> ElastiCache
    ECS2 --> ECS1
    ECS3 --> RDS
    ECS3 --> ElastiCache
    ECS3 --> SES
    ECS1 --> CloudWatch
    ECS2 --> CloudWatch
    ECS3 --> CloudWatch
\`\`\`

#### Terraform設定例

\`\`\`hcl
# terraform/main.tf
terraform {
  required_version = ">= 1.0"
  
  backend "s3" {
    bucket = "your-terraform-state"
    key    = "production/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

# VPC
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "business-platform-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-northeast-1a", "ap-northeast-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = false

  tags = {
    Environment = "production"
  }
}

# RDS
resource "aws_db_instance" "main" {
  identifier           = "business-platform-db"
  engine              = "postgres"
  engine_version      = "15.3"
  instance_class      = "db.t3.medium"
  allocated_storage   = 100
  storage_encrypted   = true
  
  db_name  = "production"
  username = var.db_username
  password = var.db_password

  multi_az               = true
  backup_retention_period = 30
  backup_window          = "03:00-04:00"
  maintenance_window     = "mon:04:00-mon:05:00"

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  tags = {
    Environment = "production"
  }
}

# ElastiCache Redis
resource "aws_elasticache_cluster" "main" {
  cluster_id           = "business-platform-redis"
  engine               = "redis"
  node_type            = "cache.t3.medium"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  engine_version       = "7.0"
  port                 = 6379

  subnet_group_name    = aws_elasticache_subnet_group.main.name
  security_group_ids   = [aws_security_group.redis.id]

  tags = {
    Environment = "production"
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "business-platform-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# S3 Bucket
resource "aws_s3_bucket" "assets" {
  bucket = "business-platform-assets"

  tags = {
    Environment = "production"
  }
}

resource "aws_s3_bucket_public_access_block" "assets" {
  bucket = aws_s3_bucket.assets.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
\`\`\`

#### CI/CDパイプライン

\`\`\`yaml
# .github/workflows/deploy.yml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Run Tests
        run: |
          docker-compose -f docker-compose.test.yml up --abort-on-container-exit
          
  build-and-deploy:
    needs: test
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ap-northeast-1

      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v1

      - name: Build and push Backend image
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          ECR_REPOSITORY: business-platform-backend
          IMAGE_TAG: ${{ github.sha }}
        run: |
          docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG ./backend
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG

      - name: Build and push Frontend image
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          ECR_REPOSITORY: business-platform-frontend
          IMAGE_TAG: ${{ github.sha }}
        run: |
          docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG ./frontend
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG

      - name: Deploy to ECS
        run: |
          aws ecs update-service --cluster business-platform-cluster \
            --service backend-service --force-new-deployment
          aws ecs update-service --cluster business-platform-cluster \
            --service frontend-service --force-new-deployment

      - name: Run Database Migrations
        run: |
          aws ecs run-task --cluster business-platform-cluster \
            --task-definition migrate-task \
            --launch-type FARGATE \
            --network-configuration "awsvpcConfiguration={subnets=[subnet-xxx],securityGroups=[sg-xxx]}"
\`\`\`

### モニタリングとアラート

\`\`\`yaml
# cloudwatch-alarms.yml
Resources:
  HighCPUAlarm:
    Type: AWS::CloudWatch::Alarm
    Properties:
      AlarmName: HighCPUUtilization
      AlarmDescription: CPU使用率が80%を超えました
      MetricName: CPUUtilization
      Namespace: AWS/ECS
      Statistic: Average
      Period: 300
      EvaluationPeriods: 2
      Threshold: 80
      ComparisonOperator: GreaterThanThreshold
      AlarmActions:
        - !Ref SNSTopic

  HighMemoryAlarm:
    Type: AWS::CloudWatch::Alarm
    Properties:
      AlarmName: HighMemoryUtilization
      AlarmDescription: メモリ使用率が80%を超えました
      MetricName: MemoryUtilization
      Namespace: AWS/ECS
      Statistic: Average
      Period: 300
      EvaluationPeriods: 2
      Threshold: 80
      ComparisonOperator: GreaterThanThreshold
      AlarmActions:
        - !Ref SNSTopic

  HighErrorRateAlarm:
    Type: AWS::CloudWatch::Alarm
    Properties:
      AlarmName: HighErrorRate
      AlarmDescription: エラー率が5%を超えました
      MetricName: 5XXError
      Namespace: AWS/ApplicationELB
      Statistic: Sum
      Period: 300
      EvaluationPeriods: 1
      Threshold: 10
      ComparisonOperator: GreaterThanThreshold
      AlarmActions:
        - !Ref SNSTopic
\`\`\`

## まとめ

本設計書では、ビジネス効率化プラットフォームの包括的な技術設計を定義しました。

### 主要な設計決定

1. **技術スタック**: Next.js + Ruby on Rails の組み合わせにより、モダンなフロントエンドと堅牢なバックエンドを実現
2. **アーキテクチャ**: レイヤー化されたアーキテクチャにより、保守性とスケーラビリティを確保
3. **セキュリティ**: OWASP Top 10 対策を含む多層的なセキュリティ設計
4. **パフォーマンス**: キャッシング、CDN、データベース最適化による高速なレスポンス
5. **テスト戦略**: ユニットテスト、プロパティベーステスト、統合テスト、E2Eテストの組み合わせ
6. **アクセシビリティ**: WCAG 2.1 AA準拠による包括的なアクセシビリティ

### 次のステップ

設計書の承認後、以下のタスクに進みます：

1. データベーススキーマの実装
2. APIエンドポイントの実装
3. フロントエンドコンポーネントの実装
4. テストの作成と実行
5. デプロイメントパイプラインの構築
6. 本番環境へのデプロイ

### 参考資料

- [Next.js Documentation](https://nextjs.org/docs)
- [Ruby on Rails Guides](https://guides.rubyonrails.org/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)

