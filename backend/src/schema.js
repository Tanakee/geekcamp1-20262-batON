import { gql } from 'apollo-server-express';

export const typeDefs = gql`
  type User {
    id: ID!
    email: String!
    name: String!
    profileImageUrl: String
    bio: String
    isPublic: Boolean!
    createdAt: String!
    updatedAt: String!
  }

  type Benefactor {
    id: ID!
    userId: ID!
    name: String!
    relation: String
    kindnessDescription: String
    imageUrl: String
    kindnessActCount: Int!
    createdAt: String!
    updatedAt: String!
  }

  type KindnessAct {
    id: ID!
    userId: ID!
    benefactorId: ID!
    title: String!
    description: String
    category: String!
    actDate: String!
    location: String
    recipientName: String!
    imageUrls: [String]
    isReported: Boolean!
    reportedAt: String
    createdAt: String!
    updatedAt: String!
  }

  type Report {
    id: ID!
    kindnessActId: ID!
    benefactorId: ID!
    userId: ID!
    message: String!
    status: String!
    createdAt: String!
    sentAt: String
  }

  type Query {
    # ユーザー関連
    user(id: ID!): User
    currentUser: User

    # 恩人関連
    benefactors(userId: ID!): [Benefactor]
    benefactor(id: ID!): Benefactor

    # 活動関連
    kindnessActs(userId: ID!): [KindnessAct]
    kindnessAct(id: ID!): KindnessAct

    # 報告関連
    reports(userId: ID!): [Report]
    report(id: ID!): Report

    # ヘルスチェック
    health: String
  }

  type AuthPayload {
    token: String!
    user: User!
  }

  type Mutation {
    # 認証
    register(email: String!, name: String!, password: String!): AuthPayload!
    login(email: String!, password: String!): AuthPayload!

    # ユーザー
    createUser(email: String!, name: String!, password: String!): User
    updateUser(id: ID!, name: String, bio: String, isPublic: Boolean): User

    # 恩人
    createBenefactor(userId: ID!, name: String!, relation: String, kindnessDescription: String): Benefactor
    updateBenefactor(id: ID!, name: String, relation: String, kindnessDescription: String): Benefactor
    deleteBenefactor(id: ID!): Boolean

    # 活動
    createKindnessAct(
      userId: ID!
      benefactorId: ID!
      title: String!
      description: String
      category: String!
      actDate: String!
      location: String
      recipientName: String!
    ): KindnessAct
    updateKindnessAct(id: ID!, title: String, description: String): KindnessAct
    deleteKindnessAct(id: ID!): Boolean

    # 報告
    createReport(kindnessActId: ID!, benefactorId: ID!, userId: ID!, message: String!): Report
    sendReport(id: ID!): Report
  }
`;
