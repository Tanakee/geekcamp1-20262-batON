import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';

const generateToken = (userId) => {
  return jwt.sign({ userId }, process.env.JWT_SECRET || 'dev-secret', {
    expiresIn: process.env.JWT_EXPIRY || '24h'
  });
};

const mapUser = (row) => row ? {
  id: row.id,
  email: row.email,
  name: row.name,
  avatarUrl: row.avatar_url,
  bio: row.bio,
  skills: row.skills || [],
  rating: parseFloat(row.rating) || 5.0,
  totalRatings: row.total_ratings || 0,
  followersCount: row.followers_count || 0,
  followingCount: row.following_count || 0,
  postsCount: row.posts_count || 0,
  completedActsCount: row.completed_acts_count || 0,
  isActive: row.is_active !== false,
  createdAt: row.created_at,
  updatedAt: row.updated_at
} : null;

const mapPost = (row) => row ? {
  id: row.id,
  userId: row.user_id,
  type: row.type,
  title: row.title,
  description: row.description,
  category: row.category,
  tags: row.tags || [],
  location: row.location,
  status: row.status || 'open',
  likesCount: row.likes_count || 0,
  commentsCount: row.comments_count || 0,
  createdAt: row.created_at,
  updatedAt: row.updated_at
} : null;

const mapActivity = (row) => row ? {
  id: row.id,
  postId: row.post_id,
  initiatorId: row.initiator_id,
  helperId: row.helper_id,
  description: row.description,
  status: row.status || 'in_progress',
  completedAt: row.completed_at,
  ratingFromInitiator: row.rating_from_initiator ? parseFloat(row.rating_from_initiator) : null,
  ratingFromHelper: row.rating_from_helper ? parseFloat(row.rating_from_helper) : null,
  reviewFromInitiator: row.review_from_initiator,
  reviewFromHelper: row.review_from_helper,
  createdAt: row.created_at,
  updatedAt: row.updated_at
} : null;

const mapMessage = (row) => row ? {
  id: row.id,
  conversationId: row.conversation_id,
  senderId: row.sender_id,
  content: row.content,
  readAt: row.read_at,
  createdAt: row.created_at
} : null;

const mapConversation = (row) => row ? {
  id: row.id,
  user1Id: row.user1_id,
  user2Id: row.user2_id,
  lastMessageAt: row.last_message_at,
  createdAt: row.created_at
} : null;

const mapConnection = (row) => row ? {
  id: row.id,
  user1Id: row.user1_id,
  user2Id: row.user2_id,
  type: row.type || 'follow',
  status: row.status || 'accepted',
  createdAt: row.created_at,
  updatedAt: row.updated_at
} : null;

const mapNotification = (row) => row ? {
  id: row.id,
  userId: row.user_id,
  type: row.type,
  relatedUserId: row.related_user_id,
  relatedPostId: row.related_post_id,
  relatedActivityId: row.related_activity_id,
  title: row.title,
  message: row.message,
  readAt: row.read_at,
  createdAt: row.created_at
} : null;

const mapNotificationSettings = (row) => row ? {
  id: row.id,
  userId: row.user_id,
  matchNotifications: row.match_notifications !== false,
  messageNotifications: row.message_notifications !== false,
  commentNotifications: row.comment_notifications !== false,
  likeNotifications: row.like_notifications !== false,
  followNotifications: row.follow_notifications !== false,
  ratingNotifications: row.rating_notifications !== false,
  createdAt: row.created_at,
  updatedAt: row.updated_at
} : null;

export const resolvers = {
  Query: {
    health: () => 'OK',

    user: async (_, { id }, { pool }) => {
      const result = await pool.query('SELECT * FROM users WHERE id = $1', [id]);
      return mapUser(result.rows[0]);
    },

    currentUser: async (_, __, { pool, userId }) => {
      if (!userId) throw new Error('未認証');
      const result = await pool.query('SELECT * FROM users WHERE id = $1', [userId]);
      return mapUser(result.rows[0]);
    },

    searchUsers: async (_, { query, limit = 20, offset = 0 }, { pool }) => {
      const result = await pool.query(
        `SELECT * FROM users
         WHERE (name ILIKE $1 OR bio ILIKE $1)
         AND is_active = true
         ORDER BY rating DESC
         LIMIT $2 OFFSET $3`,
        [`%${query}%`, limit, offset]
      );
      return result.rows.map(mapUser);
    },

    posts: async (_, { limit = 20, offset = 0, type, status, category }, { pool }) => {
      let whereClauses = [];
      let params = [];
      let paramIndex = 1;

      if (type) { whereClauses.push(`type = $${paramIndex++}`); params.push(type); }
      if (status) { whereClauses.push(`status = $${paramIndex++}`); params.push(status); }
      if (category) { whereClauses.push(`category = $${paramIndex++}`); params.push(category); }

      const where = whereClauses.length > 0 ? 'WHERE ' + whereClauses.join(' AND ') : '';
      params.push(limit, offset);

      const result = await pool.query(
        `SELECT * FROM posts ${where} ORDER BY created_at DESC LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`,
        params
      );
      return result.rows.map(mapPost);
    },

    post: async (_, { id }, { pool }) => {
      const result = await pool.query('SELECT * FROM posts WHERE id = $1', [id]);
      return mapPost(result.rows[0]);
    },

    userPosts: async (_, { userId, limit = 20, offset = 0 }, { pool }) => {
      const result = await pool.query(
        'SELECT * FROM posts WHERE user_id = $1 ORDER BY created_at DESC LIMIT $2 OFFSET $3',
        [userId, limit, offset]
      );
      return result.rows.map(mapPost);
    },

    searchPosts: async (_, { query, category, type, limit = 20, offset = 0 }, { pool }) => {
      let whereClauses = [`(title ILIKE $1 OR description ILIKE $1)`];
      let params = [`%${query}%`];
      let paramIndex = 2;

      if (type) { whereClauses.push(`type = $${paramIndex++}`); params.push(type); }
      if (category) { whereClauses.push(`category = $${paramIndex++}`); params.push(category); }

      params.push(limit, offset);

      const result = await pool.query(
        `SELECT * FROM posts WHERE ${whereClauses.join(' AND ')} ORDER BY created_at DESC LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`,
        params
      );
      return result.rows.map(mapPost);
    },

    connections: async (_, { userId, type }, { pool }) => {
      const typeClause = type ? 'AND type = $2' : '';
      const params = type ? [userId, type] : [userId];
      const result = await pool.query(
        `SELECT * FROM connections WHERE (user1_id = $1 OR user2_id = $1) ${typeClause} ORDER BY created_at DESC`,
        params
      );
      return result.rows.map(mapConnection);
    },

    followers: async (_, { userId, limit = 50, offset = 0 }, { pool }) => {
      const result = await pool.query(
        `SELECT u.* FROM users u
         JOIN connections c ON c.user1_id = u.id
         WHERE c.user2_id = $1 AND c.type = 'follow' AND c.status = 'accepted'
         ORDER BY c.created_at DESC LIMIT $2 OFFSET $3`,
        [userId, limit, offset]
      );
      return result.rows.map(mapUser);
    },

    following: async (_, { userId, limit = 50, offset = 0 }, { pool }) => {
      const result = await pool.query(
        `SELECT u.* FROM users u
         JOIN connections c ON c.user2_id = u.id
         WHERE c.user1_id = $1 AND c.type = 'follow' AND c.status = 'accepted'
         ORDER BY c.created_at DESC LIMIT $2 OFFSET $3`,
        [userId, limit, offset]
      );
      return result.rows.map(mapUser);
    },

    activities: async (_, { userId, limit = 20, offset = 0 }, { pool }) => {
      const result = await pool.query(
        `SELECT * FROM activities
         WHERE initiator_id = $1 OR helper_id = $1
         ORDER BY created_at DESC LIMIT $2 OFFSET $3`,
        [userId, limit, offset]
      );
      return result.rows.map(mapActivity);
    },

    activity: async (_, { id }, { pool }) => {
      const result = await pool.query('SELECT * FROM activities WHERE id = $1', [id]);
      return mapActivity(result.rows[0]);
    },

    conversations: async (_, { userId, limit = 20, offset = 0 }, { pool }) => {
      const result = await pool.query(
        `SELECT * FROM conversations
         WHERE user1_id = $1 OR user2_id = $1
         ORDER BY COALESCE(last_message_at, created_at) DESC LIMIT $2 OFFSET $3`,
        [userId, limit, offset]
      );
      return result.rows.map(mapConversation);
    },

    messages: async (_, { conversationId, limit = 50, offset = 0 }, { pool }) => {
      const result = await pool.query(
        `SELECT * FROM messages WHERE conversation_id = $1 ORDER BY created_at DESC LIMIT $2 OFFSET $3`,
        [conversationId, limit, offset]
      );
      return result.rows.map(mapMessage);
    },

    notifications: async (_, { userId, limit = 30, offset = 0 }, { pool }) => {
      const result = await pool.query(
        `SELECT * FROM notifications WHERE user_id = $1 ORDER BY created_at DESC LIMIT $2 OFFSET $3`,
        [userId, limit, offset]
      );
      return result.rows.map(mapNotification);
    },

    notificationSettings: async (_, { userId }, { pool }) => {
      const result = await pool.query(
        'SELECT * FROM notification_settings WHERE user_id = $1',
        [userId]
      );
      if (result.rows.length === 0) {
        const inserted = await pool.query(
          `INSERT INTO notification_settings (user_id, created_at, updated_at) VALUES ($1, NOW(), NOW()) RETURNING *`,
          [userId]
        );
        return mapNotificationSettings(inserted.rows[0]);
      }
      return mapNotificationSettings(result.rows[0]);
    },

    skills: async (_, __, { pool }) => {
      const result = await pool.query('SELECT * FROM skills ORDER BY category, name');
      return result.rows.map(r => ({
        id: r.id,
        name: r.name,
        category: r.category,
        iconUrl: r.icon_url,
        createdAt: r.created_at
      }));
    },

    getMatches: async (_, { userId, limit = 10 }, { pool }) => {
      // スキルマッチングアルゴリズム: 自分と異なるタイプの投稿をしている、スキルが合うユーザーを返す
      const result = await pool.query(
        `SELECT DISTINCT u.* FROM users u
         JOIN posts p ON p.user_id = u.id
         WHERE u.id != $1
           AND u.is_active = true
           AND p.status = 'open'
         ORDER BY u.rating DESC
         LIMIT $2`,
        [userId, limit]
      );
      return result.rows.map(mapUser);
    }
  },

  Post: {
    user: async (post, _, { pool }) => {
      const result = await pool.query('SELECT * FROM users WHERE id = $1', [post.userId]);
      return mapUser(result.rows[0]);
    }
  },

  Activity: {
    post: async (activity, _, { pool }) => {
      const result = await pool.query('SELECT * FROM posts WHERE id = $1', [activity.postId]);
      return mapPost(result.rows[0]);
    },
    initiator: async (activity, _, { pool }) => {
      const result = await pool.query('SELECT * FROM users WHERE id = $1', [activity.initiatorId]);
      return mapUser(result.rows[0]);
    },
    helper: async (activity, _, { pool }) => {
      const result = await pool.query('SELECT * FROM users WHERE id = $1', [activity.helperId]);
      return mapUser(result.rows[0]);
    }
  },

  Message: {
    sender: async (message, _, { pool }) => {
      const result = await pool.query('SELECT * FROM users WHERE id = $1', [message.senderId]);
      return mapUser(result.rows[0]);
    }
  },

  Conversation: {
    user1: async (conv, _, { pool }) => {
      const result = await pool.query('SELECT * FROM users WHERE id = $1', [conv.user1Id]);
      return mapUser(result.rows[0]);
    },
    user2: async (conv, _, { pool }) => {
      const result = await pool.query('SELECT * FROM users WHERE id = $1', [conv.user2Id]);
      return mapUser(result.rows[0]);
    }
  },

  Mutation: {
    register: async (_, { email, name, password, bio = '', skills = [] }, { pool }) => {
      const existing = await pool.query('SELECT id FROM users WHERE email = $1', [email]);
      if (existing.rows.length > 0) {
        throw new Error('このメールアドレスは既に登録されています');
      }
      const hash = await bcrypt.hash(password, 10);
      const result = await pool.query(
        `INSERT INTO users (email, name, bio, password_hash, skills, rating, total_ratings, followers_count, following_count, posts_count, completed_acts_count, is_active, created_at, updated_at)
         VALUES ($1, $2, $3, $4, $5, 5.0, 0, 0, 0, 0, 0, true, NOW(), NOW())
         RETURNING *`,
        [email, name, bio, hash, skills]
      );
      const user = mapUser(result.rows[0]);
      await pool.query(
        `INSERT INTO notification_settings (user_id, created_at, updated_at) VALUES ($1, NOW(), NOW()) ON CONFLICT DO NOTHING`,
        [user.id]
      );
      return { token: generateToken(user.id), user };
    },

    login: async (_, { email, password }, { pool }) => {
      const result = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
      const user = result.rows[0];
      if (!user) throw new Error('メールアドレスまたはパスワードが間違っています');

      const valid = await bcrypt.compare(password, user.password_hash);
      if (!valid) throw new Error('メールアドレスまたはパスワードが間違っています');

      return { token: generateToken(user.id), user: mapUser(user) };
    },

    updateProfile: async (_, { id, name, bio, avatarUrl, skills }, { pool }) => {
      let setClauses = ['updated_at = NOW()'];
      let params = [];
      let paramIndex = 1;

      if (name !== undefined) { setClauses.push(`name = $${paramIndex++}`); params.push(name); }
      if (bio !== undefined) { setClauses.push(`bio = $${paramIndex++}`); params.push(bio); }
      if (avatarUrl !== undefined) { setClauses.push(`avatar_url = $${paramIndex++}`); params.push(avatarUrl); }
      if (skills !== undefined) { setClauses.push(`skills = $${paramIndex++}`); params.push(skills); }

      params.push(id);
      const result = await pool.query(
        `UPDATE users SET ${setClauses.join(', ')} WHERE id = $${paramIndex} RETURNING *`,
        params
      );
      return mapUser(result.rows[0]);
    },

    createPost: async (_, { userId, type, title, description, category, tags = [], location }, { pool }) => {
      const result = await pool.query(
        `INSERT INTO posts (user_id, type, title, description, category, tags, location, status, likes_count, comments_count, created_at, updated_at)
         VALUES ($1, $2, $3, $4, $5, $6, $7, 'open', 0, 0, NOW(), NOW())
         RETURNING *`,
        [userId, type, title, description, category, tags, location]
      );
      await pool.query('UPDATE users SET posts_count = posts_count + 1 WHERE id = $1', [userId]);
      return mapPost(result.rows[0]);
    },

    updatePost: async (_, { id, title, description, status }, { pool }) => {
      let setClauses = ['updated_at = NOW()'];
      let params = [];
      let paramIndex = 1;

      if (title !== undefined) { setClauses.push(`title = $${paramIndex++}`); params.push(title); }
      if (description !== undefined) { setClauses.push(`description = $${paramIndex++}`); params.push(description); }
      if (status !== undefined) { setClauses.push(`status = $${paramIndex++}`); params.push(status); }

      params.push(id);
      const result = await pool.query(
        `UPDATE posts SET ${setClauses.join(', ')} WHERE id = $${paramIndex} RETURNING *`,
        params
      );
      return mapPost(result.rows[0]);
    },

    deletePost: async (_, { id }, { pool }) => {
      const postResult = await pool.query('SELECT user_id FROM posts WHERE id = $1', [id]);
      if (postResult.rows.length === 0) return false;
      const userId = postResult.rows[0].user_id;
      await pool.query('DELETE FROM posts WHERE id = $1', [id]);
      await pool.query('UPDATE users SET posts_count = GREATEST(0, posts_count - 1) WHERE id = $1', [userId]);
      return true;
    },

    followUser: async (_, { followerId, followingId }, { pool }) => {
      const existing = await pool.query(
        `SELECT * FROM connections WHERE user1_id = $1 AND user2_id = $2 AND type = 'follow'`,
        [followerId, followingId]
      );
      if (existing.rows.length > 0) return mapConnection(existing.rows[0]);

      const result = await pool.query(
        `INSERT INTO connections (user1_id, user2_id, type, status, created_at, updated_at)
         VALUES ($1, $2, 'follow', 'accepted', NOW(), NOW()) RETURNING *`,
        [followerId, followingId]
      );
      await pool.query('UPDATE users SET following_count = following_count + 1 WHERE id = $1', [followerId]);
      await pool.query('UPDATE users SET followers_count = followers_count + 1 WHERE id = $1', [followingId]);
      return mapConnection(result.rows[0]);
    },

    unfollowUser: async (_, { followerId, followingId }, { pool }) => {
      const result = await pool.query(
        `DELETE FROM connections WHERE user1_id = $1 AND user2_id = $2 AND type = 'follow' RETURNING id`,
        [followerId, followingId]
      );
      if (result.rows.length > 0) {
        await pool.query('UPDATE users SET following_count = GREATEST(0, following_count - 1) WHERE id = $1', [followerId]);
        await pool.query('UPDATE users SET followers_count = GREATEST(0, followers_count - 1) WHERE id = $1', [followingId]);
      }
      return result.rows.length > 0;
    },

    likePost: async (_, { userId, postId }, { pool }) => {
      const existing = await pool.query(
        `SELECT id FROM post_ratings WHERE post_id = $1 AND user_id = $2`,
        [postId, userId]
      );
      if (existing.rows.length === 0) {
        await pool.query(
          `INSERT INTO post_ratings (post_id, user_id, created_at) VALUES ($1, $2, NOW())`,
          [postId, userId]
        );
        await pool.query('UPDATE posts SET likes_count = likes_count + 1 WHERE id = $1', [postId]);
      }
      const result = await pool.query('SELECT * FROM posts WHERE id = $1', [postId]);
      return mapPost(result.rows[0]);
    },

    createActivity: async (_, { postId, initiatorId, helperId }, { pool }) => {
      const result = await pool.query(
        `INSERT INTO activities (post_id, initiator_id, helper_id, status, created_at, updated_at)
         VALUES ($1, $2, $3, 'in_progress', NOW(), NOW()) RETURNING *`,
        [postId, initiatorId, helperId]
      );
      await pool.query(`UPDATE posts SET status = 'matched' WHERE id = $1`, [postId]);
      return mapActivity(result.rows[0]);
    },

    completeActivity: async (_, { id }, { pool }) => {
      const result = await pool.query(
        `UPDATE activities SET status = 'completed', completed_at = NOW(), updated_at = NOW() WHERE id = $1 RETURNING *`,
        [id]
      );
      const activity = result.rows[0];
      if (activity) {
        await pool.query(`UPDATE posts SET status = 'completed' WHERE id = $1`, [activity.post_id]);
        await pool.query('UPDATE users SET completed_acts_count = completed_acts_count + 1 WHERE id = $1 OR id = $2', [activity.initiator_id, activity.helper_id]);
      }
      return mapActivity(activity);
    },

    rateActivity: async (_, { activityId, userId, rating, review }, { pool }) => {
      const actResult = await pool.query('SELECT * FROM activities WHERE id = $1', [activityId]);
      const activity = actResult.rows[0];
      if (!activity) throw new Error('活動が見つかりません');

      let updateClause;
      let reviewClause;
      let targetUserId;

      if (activity.initiator_id === userId) {
        updateClause = 'rating_from_initiator = $1';
        reviewClause = ', review_from_initiator = $3';
        targetUserId = activity.helper_id;
      } else if (activity.helper_id === userId) {
        updateClause = 'rating_from_helper = $1';
        reviewClause = ', review_from_helper = $3';
        targetUserId = activity.initiator_id;
      } else {
        throw new Error('評価権限がありません');
      }

      const result = await pool.query(
        `UPDATE activities SET ${updateClause}${review ? reviewClause : ''}, updated_at = NOW() WHERE id = $2 RETURNING *`,
        review ? [rating, activityId, review] : [rating, activityId]
      );

      // ユーザーの平均評価を更新
      const ratingResult = await pool.query(
        `SELECT AVG(COALESCE(rating_from_initiator, rating_from_helper)) as avg_rating,
                COUNT(*) as total FROM activities
         WHERE (helper_id = $1 AND rating_from_initiator IS NOT NULL)
            OR (initiator_id = $1 AND rating_from_helper IS NOT NULL)`,
        [targetUserId]
      );
      if (ratingResult.rows[0].avg_rating) {
        await pool.query(
          'UPDATE users SET rating = $1, total_ratings = $2 WHERE id = $3',
          [parseFloat(ratingResult.rows[0].avg_rating).toFixed(2), ratingResult.rows[0].total, targetUserId]
        );
      }

      return mapActivity(result.rows[0]);
    },

    sendMessage: async (_, { conversationId, senderId, content }, { pool }) => {
      const result = await pool.query(
        `INSERT INTO messages (conversation_id, sender_id, content, created_at)
         VALUES ($1, $2, $3, NOW()) RETURNING *`,
        [conversationId, senderId, content]
      );
      await pool.query(
        'UPDATE conversations SET last_message_at = NOW() WHERE id = $1',
        [conversationId]
      );
      return mapMessage(result.rows[0]);
    },

    markMessagesAsRead: async (_, { conversationId }, { pool, userId }) => {
      await pool.query(
        `UPDATE messages SET read_at = NOW()
         WHERE conversation_id = $1 AND sender_id != $2 AND read_at IS NULL`,
        [conversationId, userId || '00000000-0000-0000-0000-000000000000']
      );
      return true;
    },

    updateNotificationSettings: async (_, { userId, ...settings }, { pool }) => {
      const setClauses = ['updated_at = NOW()'];
      const params = [];
      let paramIndex = 1;

      const fields = {
        matchNotifications: 'match_notifications',
        messageNotifications: 'message_notifications',
        commentNotifications: 'comment_notifications',
        likeNotifications: 'like_notifications',
        followNotifications: 'follow_notifications',
        ratingNotifications: 'rating_notifications'
      };

      for (const [key, col] of Object.entries(fields)) {
        if (settings[key] !== undefined) {
          setClauses.push(`${col} = $${paramIndex++}`);
          params.push(settings[key]);
        }
      }

      params.push(userId);
      const result = await pool.query(
        `UPDATE notification_settings SET ${setClauses.join(', ')} WHERE user_id = $${paramIndex} RETURNING *`,
        params
      );
      return mapNotificationSettings(result.rows[0]);
    }
  }
};
