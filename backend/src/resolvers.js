export const resolvers = {
  Query: {
    health: () => 'OK',

    user: async (_, { id }, { pool }) => {
      const result = await pool.query(
        'SELECT * FROM users WHERE id = $1',
        [id]
      );
      return result.rows[0] || null;
    },

    benefactors: async (_, { userId }, { pool }) => {
      const result = await pool.query(
        'SELECT * FROM benefactors WHERE user_id = $1 ORDER BY created_at DESC',
        [userId]
      );
      return result.rows;
    },

    kindnessActs: async (_, { userId }, { pool }) => {
      const result = await pool.query(
        'SELECT * FROM kindness_acts WHERE user_id = $1 ORDER BY act_date DESC',
        [userId]
      );
      return result.rows;
    },

    reports: async (_, { userId }, { pool }) => {
      const result = await pool.query(
        'SELECT * FROM reports WHERE user_id = $1 ORDER BY created_at DESC',
        [userId]
      );
      return result.rows;
    }
  },

  Mutation: {
    createUser: async (_, { email, name, password }, { pool }) => {
      const result = await pool.query(
        `INSERT INTO users (email, name, password_hash, is_public, created_at, updated_at)
         VALUES ($1, $2, $3, $4, NOW(), NOW())
         RETURNING id, email, name, is_public, created_at, updated_at`,
        [email, name, password, true]
      );
      return result.rows[0];
    },

    createBenefactor: async (
      _,
      { userId, name, relation, kindnessDescription },
      { pool }
    ) => {
      const result = await pool.query(
        `INSERT INTO benefactors (user_id, name, relation, kindness_description, created_at, updated_at)
         VALUES ($1, $2, $3, $4, NOW(), NOW())
         RETURNING *`,
        [userId, name, relation, kindnessDescription]
      );
      return result.rows[0];
    },

    createKindnessAct: async (
      _,
      {
        userId,
        benefactorId,
        title,
        description,
        category,
        actDate,
        location,
        recipientName
      },
      { pool }
    ) => {
      const result = await pool.query(
        `INSERT INTO kindness_acts
         (user_id, benefactor_id, title, description, category, act_date, location, recipient_name, created_at, updated_at)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, NOW(), NOW())
         RETURNING *`,
        [userId, benefactorId, title, description, category, actDate, location, recipientName]
      );
      return result.rows[0];
    },

    createReport: async (
      _,
      { kindnessActId, benefactorId, userId, message },
      { pool }
    ) => {
      const result = await pool.query(
        `INSERT INTO reports (kindness_act_id, benefactor_id, user_id, message, status, created_at)
         VALUES ($1, $2, $3, $4, 'DRAFT', NOW())
         RETURNING *`,
        [kindnessActId, benefactorId, userId, message]
      );
      return result.rows[0];
    },

    sendReport: async (_, { id }, { pool }) => {
      const result = await pool.query(
        `UPDATE reports SET status = 'SENT', sent_at = NOW() WHERE id = $1 RETURNING *`,
        [id]
      );
      return result.rows[0];
    }
  }
};
