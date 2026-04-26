# 🚀 プロジェクト実行ガイド

## ❌ 現在の状況

あなたのシステムには以下が不足しています：

- ❌ **Docker** - 未インストール（PostgreSQL、Redis、コンテナ化されたサービスに必要）
- ❌ **Ruby** - 未インストール（Railsバックエンドに必要）
- ✅ **Node.js** - インストール済み (v22.18.0)

## 🎯 推奨: Dockerをインストール

これが最も簡単な方法です。

### ステップ1: Docker Desktopをインストール

1. **ダウンロード:**
   - https://www.docker.com/products/docker-desktop/
   - 「Download for Windows」をクリック

2. **インストール:**
   - ダウンロードしたファイルを実行
   - インストール完了後、コンピュータを再起動

3. **Docker Desktopを起動:**
   - スタートメニューから「Docker Desktop」を起動
   - Dockerが起動するまで待つ（数分かかる場合があります）

### ステップ2: プロジェクトを起動

Dockerが起動したら、以下のコマンドを実行：

```bash
# プロジェクトディレクトリで実行
bash start.sh
```

または手動で：

```bash
# すべてのサービスを起動
docker-compose up -d

# バックエンドの依存関係をインストール
docker-compose exec backend bundle install

# データベースをセットアップ
docker-compose exec backend rails db:create db:migrate db:seed

# フロントエンドの依存関係をインストール（既に完了）
docker-compose exec frontend npm install
```

### ステップ3: アクセス

- **フロントエンド**: http://localhost:3001
- **バックエンドAPI**: http://localhost:3000

### ステップ4: ログイン

**管理者:**
- Email: `admin@example.com`
- Password: `Admin123!@#`

**一般ユーザー:**
- Email: `user1@example.com`
- Password: `User123!@#`

---

## 🔧 代替方法: 手動インストール

Dockerを使いたくない場合は、以下をインストール：

### 1. Ruby 3.2.2をインストール

1. https://rubyinstaller.org/ にアクセス
2. 「Ruby+Devkit 3.2.2-1 (x64)」をダウンロード
3. インストール実行
4. インストール完了後、コマンドプロンプトで確認：
   ```bash
   ruby --version
   # => ruby 3.2.2 と表示されればOK
   ```

### 2. PostgreSQL 15をインストール

1. https://www.postgresql.org/download/windows/ にアクセス
2. 「Download the installer」をクリック
3. PostgreSQL 15をダウンロードしてインストール
4. インストール時に設定：
   - Password: `postgres`
   - Port: `5432`

### 3. Redisをインストール

1. https://github.com/microsoftarchive/redis/releases にアクセス
2. 「Redis-x64-3.0.504.msi」をダウンロード
3. インストール実行

### 4. プロジェクトを起動

#### バックエンド（ターミナル1）

```bash
cd backend

# 依存関係をインストール
bundle install

# データベースをセットアップ
rails db:create db:migrate db:seed

# サーバーを起動
rails server
```

#### フロントエンド（ターミナル2）

```bash
cd frontend

# 依存関係をインストール（既に完了）
npm install

# 開発サーバーを起動
npm run dev
```

### 5. アクセス

- **フロントエンド**: http://localhost:3000
- **バックエンドAPI**: http://localhost:3000

---

## 🐛 トラブルシューティング

### Docker Desktopが起動しない

1. Windows の仮想化機能を有効にする必要があります
2. BIOS設定で「Virtualization Technology」を有効化
3. Windows機能で「Hyper-V」と「WSL 2」を有効化

### ポートが既に使用されている

```bash
# ポート3000を使用しているプロセスを確認
netstat -ano | findstr :3000

# プロセスを終了（PIDを確認後）
taskkill /PID <PID> /F
```

### データベース接続エラー

```bash
# PostgreSQLが起動しているか確認
# Dockerの場合
docker-compose ps

# 手動インストールの場合
# サービスマネージャーでPostgreSQLサービスを確認
```

---

## 📝 現在の状態

### ✅ 完了していること

- ✅ プロジェクトファイルすべて作成済み
- ✅ フロントエンド依存関係インストール済み
- ✅ 全APIエンドポイント実装済み
- ✅ データベーススキーマ定義済み

### ⏳ 必要なこと

- ⏳ Docker または Ruby + PostgreSQL + Redis のインストール
- ⏳ サービスの起動
- ⏳ データベースのセットアップ

---

## 🎯 次のステップ

1. **Docker Desktopをインストール**（推奨）
   - 最も簡単で確実な方法
   - 1つのコマンドですべて起動

2. **プロジェクトを起動**
   ```bash
   bash start.sh
   ```

3. **ブラウザでアクセス**
   - http://localhost:3001

4. **ログインして確認**
   - 管理者アカウントでログイン
   - ダッシュボードを確認

---

## 💡 ヒント

- Docker Desktopのインストールには管理者権限が必要です
- 初回起動時は依存関係のダウンロードに時間がかかります（5-10分）
- すべてのサービスが起動するまで待ってからアクセスしてください

---

## 📞 サポート

問題が発生した場合：

1. Docker Desktopが起動しているか確認
2. `docker-compose ps` でサービスの状態を確認
3. `docker-compose logs` でエラーログを確認

---

**作成日**: 2024年1月15日  
**プロジェクト**: ビジネス効率化プラットフォーム  
**バージョン**: 0.6.0
