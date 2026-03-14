import { gql } from 'apollo-server-express';

export const typeDefs = gql`
  type User {
    id: ID!
    email: String!
    name: String!
    avatarUrl: String
    bio: String
    skills: [String!]
    rating: Float!
    totalRatings: Int!
    followersCount: Int!
    followingCount: Int!
    postsCount: Int!
    completedActsCount: Int!
    isActive: Boolean!
    createdAt: String!
    updatedAt: String!
  }

  type Post {
    id: ID!
    userId: ID!
    user: User
    type: String!
    title: String!
    description: String!
    category: String
    tags: [String!]
    location: String
    status: String!
    likesCount: Int!
    commentsCount: Int!
    createdAt: String!
    updatedAt: String!
  }

  type Connection {
    id: ID!
    user1Id: ID!
    user2Id: ID!
    type: String!
    status: String!
    createdAt: String!
    updatedAt: String!
  }

  type Activity {
    id: ID!
    postId: ID!
    post: Post
    initiatorId: ID!
    initiator: User
    helperId: ID!
    helper: User
    description: String
    status: String!
    completedAt: String
    ratingFromInitiator: Float
    ratingFromHelper: Float
    reviewFromInitiator: String
    reviewFromHelper: String
    createdAt: String!
    updatedAt: String!
  }

  type Message {
    id: ID!
    conversationId: ID!
    senderId: ID!
    sender: User
    content: String!
    readAt: String
    createdAt: String!
  }

  type Conversation {
    id: ID!
    user1Id: ID!
    user2Id: ID!
    user1: User
    user2: User
    lastMessageAt: String
    createdAt: String!
  }

  type Notification {
    id: ID!
    userId: ID!
    type: String!
    relatedUserId: ID
    relatedPostId: ID
    relatedActivityId: ID
    title: String
    message: String
    readAt: String
    createdAt: String!
  }

  type NotificationSettings {
    id: ID!
    userId: ID!
    matchNotifications: Boolean!
    messageNotifications: Boolean!
    postLikeNotifications: Boolean!
    postCommentNotifications: Boolean!
    followNotifications: Boolean!
    skillMatchNotifications: Boolean!
    notificationStartHour: Int!
    notificationEndHour: Int!
    createdAt: String!
    updatedAt: String!
  }

  type Skill {
    id: ID!
    name: String!
    category: String
    iconUrl: String
    createdAt: String!
  }

  type Query {
    # ユーザー関連
    user(id: ID!): User
    currentUser: User
    searchUsers(query: String!, limit: Int, offset: Int): [User!]

    # ポスト関連
    posts(limit: Int, offset: Int, type: String, status: String, category: String): [Post!]
    post(id: ID!): Post
    userPosts(userId: ID!, limit: Int, offset: Int): [Post!]
    searchPosts(query: String!, category: String, type: String, limit: Int, offset: Int): [Post!]

    # コネクション関連
    connections(userId: ID!, type: String): [Connection!]
    followers(userId: ID!, limit: Int, offset: Int): [User!]
    following(userId: ID!, limit: Int, offset: Int): [User!]

    # 活動関連
    activities(userId: ID!, limit: Int, offset: Int): [Activity!]
    activity(id: ID!): Activity

    # メッセージング
    conversations(userId: ID!, limit: Int, offset: Int): [Conversation!]
    messages(conversationId: ID!, limit: Int, offset: Int): [Message!]

    # 通知
    notifications(userId: ID!, limit: Int, offset: Int): [Notification!]
    notificationSettings(userId: ID!): NotificationSettings

    # スキル
    skills: [Skill!]

    # マッチング
    getMatches(userId: ID!, limit: Int): [User!]

    # ヘルスチェック
    health: String
  }

  type AuthPayload {
    token: String!
    user: User!
  }

  type Mutation {
    # 認証
    register(email: String!, name: String!, password: String!, bio: String, skills: [String!]): AuthPayload!
    login(email: String!, password: String!): AuthPayload!

    # ユーザー
    updateProfile(
      id: ID!
      name: String
      bio: String
      avatarUrl: String
      skills: [String!]
    ): User

    # ポスト
    createPost(
      userId: ID!
      type: String!
      title: String!
      description: String!
      category: String
      tags: [String!]
      location: String
    ): Post!
    updatePost(
      id: ID!
      title: String
      description: String
      status: String
    ): Post
    deletePost(id: ID!): Boolean!

    # コネクション
    followUser(followerId: ID!, followingId: ID!): Connection!
    unfollowUser(followerId: ID!, followingId: ID!): Boolean!
    likePost(userId: ID!, postId: ID!): Post!

    # 活動
    createActivity(postId: ID!, initiatorId: ID!, helperId: ID!): Activity!
    completeActivity(id: ID!): Activity!
    rateActivity(
      activityId: ID!
      userId: ID!
      rating: Float!
      review: String
    ): Activity!

    # メッセージング
    sendMessage(conversationId: ID!, senderId: ID!, content: String!): Message!
    markMessagesAsRead(conversationId: ID!): Boolean!

    # 通知設定
    updateNotificationSettings(
      userId: ID!
      matchNotifications: Boolean
      messageNotifications: Boolean
      postLikeNotifications: Boolean
      postCommentNotifications: Boolean
      followNotifications: Boolean
      skillMatchNotifications: Boolean
      notificationStartHour: Int
      notificationEndHour: Int
    ): NotificationSettings!
  }
`;
