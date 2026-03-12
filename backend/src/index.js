import express from 'express';
import cors from 'cors';
import { ApolloServer } from 'apollo-server-express';
import { typeDefs } from './schema.js';
import { resolvers } from './resolvers.js';
import { createPool } from './db.js';
import { RedisClient } from './redis.js';

const PORT = process.env.PORT || 3000;
const app = express();

// ミドルウェア
app.use(cors());
app.use(express.json());

// ヘルスチェックエンドポイント
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// GraphQL サーバー起動
const startServer = async () => {
  try {
    // データベース接続テスト
    const pool = createPool();
    const client = await pool.connect();
    console.log('✅ PostgreSQL に接続しました');
    client.release();

    // Redis 接続テスト
    const redis = new RedisClient();
    await redis.connect();
    await redis.ping();
    console.log('✅ Redis に接続しました');

    // Apollo Server 起動
    const server = new ApolloServer({
      typeDefs,
      resolvers,
      context: async () => ({
        pool,
        redis
      })
    });

    await server.start();
    server.applyMiddleware({ app });

    // サーバー起動
    app.listen(PORT, () => {
      console.log(`\n🚀 Bat-On API Server が起動しました`);
      console.log(`📍 ポート: ${PORT}`);
      console.log(`🔗 GraphQL: http://localhost:${PORT}${server.graphqlPath}`);
      console.log(`\n開発環境: ${process.env.NODE_ENV}`);
    });
  } catch (error) {
    console.error('❌ サーバー起動エラー:', error);
    process.exit(1);
  }
};

startServer();
