# batON 🏹

> 恩を送り、つながりを紡ぐ — 恩送りアプリ

## 概要

受けた恩を別の誰かへ「バトン」のように繋いでいく、恩送り記録・可視化アプリです。

## 構成

```
batON/
├── ios/       # SwiftUI iOSアプリ
├── backend/   # Node.js + Apollo GraphQL API
└── docs/      # 仕様書・設計書
```

## 技術スタック

| 領域 | 技術 |
|------|------|
| iOS | Swift / SwiftUI / SceneKit |
| API | Node.js / Express / Apollo GraphQL |
| DB | PostgreSQL 16 |
| Cache | Redis 7 |
| 開発環境 | Docker / Docker Compose |

## 開発環境のセットアップ

```bash
cp .env.example .env
docker compose up -d
```

API: http://localhost:3000/graphql
