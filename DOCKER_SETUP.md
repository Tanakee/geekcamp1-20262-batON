# Docker 開発環境セットアップ

## 概要

このプロジェクトでは Docker & Docker Compose を使用して、開発環境を統一しています。

- **PostgreSQL 16** - データベース
- **Redis 7** - キャッシュ & セッション管理
- **Node.js API** - GraphQL サーバー（Express + Apollo）

---

## 必要なツール

1. **Docker Desktop** をインストール
   - [https://www.docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop)
   - Mac / Windows / Linux に対応

2. **インストール確認**
   ```bash
   docker --version
   docker-compose --version
   ```

---

## 開発環境の起動

### 1. 環境変数設定

```bash
# .env.example をコピー
cp .env.example .env
```

### 2. Docker コンテナを起動

```bash
# すべてのコンテナを起動
docker-compose up -d

# ログを表示（確認用）
docker-compose logs -f
```

### 3. 起動確認

```bash
# コンテナが起動しているか確認
docker-compose ps

# 接続テスト
curl http://localhost:3000/health
# 返り値: {"status":"ok","timestamp":"..."}
```

---

## 各サービスへのアクセス

| サービス | URL | 認証情報 |
|---------|-----|--------|
| **PostgreSQL** | localhost:5432 | user: `baton_user`<br>password: `baton_password`<br>database: `baton_db` |
| **Redis** | localhost:6379 | - |
| **GraphQL API** | http://localhost:3000/graphql | - |
| **Health Check** | http://localhost:3000/health | - |

---

## よく使うコマンド

```bash
# コンテナ起動
docker-compose up -d

# コンテナ停止
docker-compose down

# ログ表示（リアルタイム）
docker-compose logs -f api

# 特定コンテナを再起動
docker-compose restart api

# データベースシェルにアクセス
docker-compose exec postgres psql -U baton_user -d baton_db

# Redis にアクセス
docker-compose exec redis redis-cli

# コンテナ削除（データベースリセット）
docker-compose down -v
```

---

## 開発フロー

### API サーバーの修正

```bash
# backend/src/*.js を修正
# nodemon が自動的に再起動

# ログ確認
docker-compose logs -f api
```

### データベースの変更

```bash
# backend/init.sql に SQL を追加
# コンテナを再起動
docker-compose down -v
docker-compose up -d
```

### 新しい npm パッケージの追加

```bash
# package.json に依存関係を追加
# コンテナを再起動
docker-compose restart api
```

---

## トラブルシューティング

### ポート競合エラー
```bash
# 既存のコンテナ停止
docker-compose down

# キャッシュクリア
docker-compose down -v
```

### メモリ不足
```bash
# Docker のメモリ設定を増やす
# Docker Desktop Settings > Resources > Memory: 4GB 以上推奨
```

### データベース接続エラー
```bash
# PostgreSQL のヘルスチェック確認
docker-compose exec postgres pg_isready -U baton_user

# ログ確認
docker-compose logs postgres
```

---

## GraphQL クエリ例

```bash
curl -X POST http://localhost:3000/graphql \
  -H "Content-Type: application/json" \
  -d '{
    "query": "{ health }"
  }'
```

---

## チーム開発での利点

✅ **環境統一**: すべてのチームメンバーが同じバージョンで開発
✅ **セットアップ簡単**: `docker-compose up` だけで完全な環境構築
✅ **本番環境と同一**: Docker イメージを本番にそのままデプロイ可能
✅ **隔離**: ローカル環境に影響なし
✅ **簡単なリセット**: `docker-compose down -v` でクリーンスレート

---

## 次のステップ

- [ ] API 実装開始
- [ ] GraphQL スキーマ拡張
- [ ] テスト環境構築
- [ ] CI/CD パイプライン設定
- [ ] 本番環境デプロイ（AWS ECS）
