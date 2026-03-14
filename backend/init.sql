-- Bat-On SNS プラットフォーム データベース初期化スクリプト

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- スキル種別テーブル
CREATE TABLE IF NOT EXISTS skills (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) UNIQUE NOT NULL,
  category VARCHAR(50),
  icon_url VARCHAR(500),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ユーザーテーブル（SNS対応）
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  password_hash VARCHAR(255),
  avatar_url VARCHAR(500),
  bio TEXT,
  skills TEXT[],
  rating DECIMAL(3, 2) DEFAULT 5.0,
  total_ratings INTEGER DEFAULT 0,
  followers_count INTEGER DEFAULT 0,
  following_count INTEGER DEFAULT 0,
  posts_count INTEGER DEFAULT 0,
  completed_acts_count INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 投稿テーブル（help_offer / help_request）
CREATE TABLE IF NOT EXISTS posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type VARCHAR(20) NOT NULL CHECK (type IN ('help_offer', 'help_request')),
  title VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  category VARCHAR(50),
  tags TEXT[],
  location VARCHAR(255),
  status VARCHAR(20) DEFAULT 'open' CHECK (status IN ('open', 'matched', 'completed', 'closed')),
  likes_count INTEGER DEFAULT 0,
  comments_count INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- コネクション（フォロー・マッチング）テーブル
CREATE TABLE IF NOT EXISTS connections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user1_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  user2_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type VARCHAR(20) DEFAULT 'follow' CHECK (type IN ('follow', 'match')),
  status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected', 'blocked')),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT different_users CHECK (user1_id != user2_id)
);

-- 活動テーブル（完了した恩送り）
CREATE TABLE IF NOT EXISTS activities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  initiator_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  helper_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  description TEXT,
  status VARCHAR(20) DEFAULT 'in_progress' CHECK (status IN ('in_progress', 'completed', 'cancelled')),
  completed_at TIMESTAMP,
  rating_from_initiator DECIMAL(3, 2),
  rating_from_helper DECIMAL(3, 2),
  review_from_initiator TEXT,
  review_from_helper TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- メッセージテーブル
CREATE TABLE IF NOT EXISTS messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  read_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 会話テーブル
CREATE TABLE IF NOT EXISTS conversations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user1_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  user2_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  last_message_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT different_users CHECK (user1_id != user2_id)
);

-- 通知テーブル
CREATE TABLE IF NOT EXISTS notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type VARCHAR(50) NOT NULL,
  related_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  related_post_id UUID REFERENCES posts(id) ON DELETE SET NULL,
  related_activity_id UUID REFERENCES activities(id) ON DELETE SET NULL,
  title VARCHAR(255),
  message TEXT,
  read_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 通知設定テーブル
CREATE TABLE IF NOT EXISTS notification_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  match_notifications BOOLEAN DEFAULT true,
  message_notifications BOOLEAN DEFAULT true,
  post_like_notifications BOOLEAN DEFAULT true,
  post_comment_notifications BOOLEAN DEFAULT true,
  follow_notifications BOOLEAN DEFAULT true,
  skill_match_notifications BOOLEAN DEFAULT true,
  notification_start_hour INT DEFAULT 8,
  notification_end_hour INT DEFAULT 22,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ポストレーティングテーブル
CREATE TABLE IF NOT EXISTS post_ratings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  rating DECIMAL(3, 2),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT unique_user_post_rating UNIQUE (post_id, user_id)
);

-- インデックス
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_name ON users(name);
CREATE INDEX IF NOT EXISTS idx_posts_user_id ON posts(user_id);
CREATE INDEX IF NOT EXISTS idx_posts_type ON posts(type);
CREATE INDEX IF NOT EXISTS idx_posts_status ON posts(status);
CREATE INDEX IF NOT EXISTS idx_posts_created_at ON posts(created_at);
CREATE INDEX IF NOT EXISTS idx_connections_user1_id ON connections(user1_id);
CREATE INDEX IF NOT EXISTS idx_connections_user2_id ON connections(user2_id);
CREATE INDEX IF NOT EXISTS idx_connections_status ON connections(status);
CREATE INDEX IF NOT EXISTS idx_activities_post_id ON activities(post_id);
CREATE INDEX IF NOT EXISTS idx_activities_initiator_id ON activities(initiator_id);
CREATE INDEX IF NOT EXISTS idx_activities_helper_id ON activities(helper_id);
CREATE INDEX IF NOT EXISTS idx_messages_conversation_id ON messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_messages_sender_id ON messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_conversations_user1_id ON conversations(user1_id);
CREATE INDEX IF NOT EXISTS idx_conversations_user2_id ON conversations(user2_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_read_at ON notifications(read_at);
CREATE INDEX IF NOT EXISTS idx_post_ratings_post_id ON post_ratings(post_id);
CREATE INDEX IF NOT EXISTS idx_post_ratings_user_id ON post_ratings(user_id);

-- 初期スキルデータ
INSERT INTO skills (name, category) VALUES
('プログラミング', 'IT'),
('ウェブデザイン', 'IT'),
('データ分析', 'IT'),
('英語教育', '教育'),
('日本語教育', '教育'),
('ビジネスコンサル', 'ビジネス'),
('マーケティング', 'ビジネス'),
('イラスト', 'クリエイティブ'),
('写真', 'クリエイティブ'),
('動画編集', 'クリエイティブ'),
('料理', 'ライフスタイル'),
('フィットネス', 'ライフスタイル'),
('ガーデニング', 'ライフスタイル'),
('音楽', 'エンターテイメント'),
('執筆', 'エンターテイメント')
ON CONFLICT (name) DO NOTHING;
