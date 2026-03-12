import { createClient } from 'redis';

export class RedisClient {
  constructor() {
    this.client = createClient({
      url: process.env.REDIS_URL || 'redis://localhost:6379'
    });

    this.client.on('error', (err) => {
      console.error('Redis Client Error', err);
    });

    this.client.on('connect', () => {
      console.log('Redis に接続しました');
    });
  }

  async connect() {
    await this.client.connect();
  }

  async ping() {
    const response = await this.client.ping();
    return response === 'PONG';
  }

  async get(key) {
    return await this.client.get(key);
  }

  async set(key, value, ttl = 3600) {
    if (ttl) {
      return await this.client.setEx(key, ttl, value);
    }
    return await this.client.set(key, value);
  }

  async del(key) {
    return await this.client.del(key);
  }

  async incr(key) {
    return await this.client.incr(key);
  }

  async lpush(key, value) {
    return await this.client.lPush(key, value);
  }

  async lrange(key, start, stop) {
    return await this.client.lRange(key, start, stop);
  }

  async disconnect() {
    await this.client.disconnect();
  }
}
