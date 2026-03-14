# バットオン（batON）データベーススキーマ移行ガイド

## 概要

このドキュメントは、個人の恩送り記録アプリから**SNS型プラットフォーム**への転換に伴うデータベーススキーマの移行戦略を説明しています。

## 旧スキーマから新スキーマへの変更

### 主な変更点

#### 1. ユーザーテーブル（users）の拡張
**旧構造**:
- 基本的なユーザー情報のみ

**新構造**:
- `bio` - ユーザーの自己紹介テキスト
- `skills` - ユーザーが持つスキルの配列
- `avatar_url` - プロフィール画像URL
- `rating` / `total_ratings` - ユーザー評価システム
- `followers_count` / `following_count` - SNSフォロー機能
- `posts_count` / `completed_acts_count` - 活動統計

#### 2. 新しいテーブルの追加

| テーブル名 | 目的 | 主要フィールド |
|-----------|------|--------------|
| `posts` | ポスト（恩送り案件）管理 | type (help_offer/help_request), title, description, category, status |
| `connections` | ユーザー間の関係管理 | user1_id, user2_id, type (follow/match), status |
| `messages` | ダイレクトメッセージ | conversation_id, sender_id, content, read_at |
| `conversations` | DM会話スレッド | user1_id, user2_id, last_message_at |
| `notifications` | ユーザー通知 | type, related_user_id, related_post_id, read_at |
| `notification_settings` | 通知設定 | 各通知種別のON/OFF、通知時間帯 |
| `activities` | 案件の実施状況 | post_id, initiator_id, helper_id, status |
| `post_ratings` | ポストへの評価 | post_id, user_id, rating |

#### 3. 削除されたテーブル（互換性維持目的でバックアップ）
- `kindness_acts` → `activities` に統合・再設計
- `benefactors` → `connections` + `users` に統合
- `reports` → `post_ratings` + `notifications` に統合

## マイグレーション戦略

### Phase 1: スキーマ準備
```sql
-- 新スキーマで初期化
psql -U postgres -d batondb -f backend/init.sql
```

### Phase 2: テストデータ投入
```sql
-- サンプルユーザー、ポスト、会話を作成
-- init.sql に含まれる INSERT 文で自動投入
```

### Phase 3: API・フロントエンド連携
- GraphQL スキーマの確認
- リゾルバー実装の確認
- iOS アプリの更新

### Phase 4: 本運用への移行
1. 既存データのバックアップ
2. 新スキーマへの完全移行
3. モニタリング・ログ確認

## テーブル詳細

### posts テーブル
```sql
CREATE TABLE posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,                    -- ポスト作成者
  type VARCHAR(20) NOT NULL,                -- 'help_offer' or 'help_request'
  title VARCHAR(255) NOT NULL,              -- ポストタイトル
  description TEXT NOT NULL,                -- 詳細説明
  category VARCHAR(100),                    -- カテゴリ（プログラミング等）
  tags TEXT[],                              -- タグ配列
  location VARCHAR(255),                    -- 場所（任意）
  status VARCHAR(20) DEFAULT 'open',        -- ステータス
  likes_count INT DEFAULT 0,                -- いいね数
  comments_count INT DEFAULT 0,             -- コメント数
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### conversations & messages テーブル
DM機能を支援:
```sql
CREATE TABLE conversations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user1_id UUID NOT NULL,
  user2_id UUID NOT NULL,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID NOT NULL,
  sender_id UUID NOT NULL,
  content TEXT NOT NULL,
  read_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### notifications テーブル
ユーザーへの通知管理:
```sql
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  type VARCHAR(50) NOT NULL,     -- match, message, like, comment, follow等
  title VARCHAR(255),
  message TEXT,
  related_user_id UUID,          -- 関連するユーザー
  related_post_id UUID,          -- 関連するポスト
  read_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## インデックス戦略

パフォーマンス最適化のため以下のインデックスを設定:

```sql
-- ユーザー関連
CREATE INDEX idx_users_email ON users(email);

-- ポスト関連
CREATE INDEX idx_posts_user_id ON posts(user_id);
CREATE INDEX idx_posts_status ON posts(status);

-- メッセージング
CREATE INDEX idx_messages_conversation_id ON messages(conversation_id);
CREATE INDEX idx_conversations_user1_id ON conversations(user1_id);
CREATE INDEX idx_conversations_user2_id ON conversations(user2_id);

-- 通知
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_read_at ON notifications(read_at);
```

## テストデータ

### サンプルユーザー
```
- tanaka@example.com (田中太郎) - プログラマー
- yamada@example.com (山田花子) - デザイナー
- suzuki@example.com (鈴木一郎) - ビジネスコンサル
- sato@example.com (佐藤美優) - 英語講師
```

### サンプルポスト
- 「Swiftアプリ開発のお手伝いします」 (help_offer)

## 環境構築

```bash
# PostgreSQL の起動
docker run --name batondb -e POSTGRES_PASSWORD=password -p 5432:5432 -d postgres:15

# データベース作成
createdb -U postgres batondb

# スキーマ・初期データ投入
psql -U postgres -d batondb -f backend/init.sql
```

## トラブルシューティング

### コンフリクト エラー
問題: `INSERT INTO ... ON CONFLICT DO NOTHING` で重複エラー
対処: 既存データを確認し、必要に応じて DELETE で削除

### 外部キー制約エラー
問題: `user_id` が存在しないなどのFK違反
対処: テーブル作成順序を確認（users → posts → messages の順序で作成）

### インデックス作成失敗
問題: `CREATE INDEX IF NOT EXISTS` で既存インデックスとの競合
対処: `DROP INDEX IF EXISTS` で既存インデックスを削除後、再実行

## まとめ

新しいスキーマは SNS 機能を完全にサポートし、以下を実現します:

✅ ユーザー間のフォロー・マッチング機能
✅ ポスト（案件）の投稿・検索・マッチング
✅ ダイレクトメッセージング
✅ 通知システム（カスタマイズ可能）
✅ スキルベースのマッチング
✅ 評価・レーティング機能

初期化スクリプトで自動投入されるテストデータを使用して、機能の動作確認ができます。
