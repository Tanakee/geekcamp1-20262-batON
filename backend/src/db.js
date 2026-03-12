import pg from 'pg';

const { Pool } = pg;

export const createPool = () => {
  const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    max: 20,
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 2000
  });

  pool.on('error', (err) => {
    console.error('Unexpected error on idle client', err);
  });

  return pool;
};

export const initializeDatabase = async (pool) => {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    // テーブル作成
    await client.query(`
      CREATE TABLE IF NOT EXISTS users (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        email VARCHAR(255) UNIQUE NOT NULL,
        name VARCHAR(255) NOT NULL,
        password_hash VARCHAR(255),
        profile_image_url VARCHAR(500),
        bio TEXT,
        is_public BOOLEAN DEFAULT true,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );

      CREATE TABLE IF NOT EXISTS benefactors (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        name VARCHAR(255) NOT NULL,
        relation VARCHAR(100),
        kindness_description TEXT,
        image_url VARCHAR(500),
        kindness_act_count INTEGER DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );

      CREATE TABLE IF NOT EXISTS kindness_acts (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        benefactor_id UUID NOT NULL REFERENCES benefactors(id) ON DELETE CASCADE,
        title VARCHAR(255) NOT NULL,
        description TEXT,
        category VARCHAR(50) NOT NULL,
        act_date DATE NOT NULL,
        location VARCHAR(255),
        recipient_name VARCHAR(255) NOT NULL,
        image_urls TEXT[],
        is_reported BOOLEAN DEFAULT false,
        reported_at TIMESTAMP,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );

      CREATE TABLE IF NOT EXISTS reports (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        kindness_act_id UUID NOT NULL REFERENCES kindness_acts(id) ON DELETE CASCADE,
        benefactor_id UUID NOT NULL REFERENCES benefactors(id) ON DELETE CASCADE,
        user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        message TEXT NOT NULL,
        status VARCHAR(20) DEFAULT 'DRAFT',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        sent_at TIMESTAMP
      );

      CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
      CREATE INDEX IF NOT EXISTS idx_benefactors_user_id ON benefactors(user_id);
      CREATE INDEX IF NOT EXISTS idx_kindness_acts_user_id ON kindness_acts(user_id);
      CREATE INDEX IF NOT EXISTS idx_kindness_acts_benefactor_id ON kindness_acts(benefactor_id);
      CREATE INDEX IF NOT EXISTS idx_reports_user_id ON reports(user_id);
    `);

    await client.query('COMMIT');
    console.log('✅ データベーステーブルを初期化しました');
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('❌ データベース初期化エラー:', error);
    throw error;
  } finally {
    client.release();
  }
};
