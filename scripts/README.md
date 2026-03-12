# Scripts

開発効率化スクリプト集

## pr-setup.sh

ブランチ作成 → コミット → PR作成を一発で実行します。

### 使い方

```bash
# 基本形：ブランチ名だけ指定
./scripts/pr-setup.sh "feature/api-connection"

# PR タイトル指定
./scripts/pr-setup.sh "feature/jwt-auth" "JWT認証実装"

# PR説明文も指定
./scripts/pr-setup.sh "feature/api-connection" "GraphQL API実装" "$(cat <<'EOF'
## 概要
GraphQL APIの実装

## 実装内容
- [ ] User mutation
- [ ] Benefactor queries

🤖 Generated with Claude Code
EOF
)"
```

### 実行フロー

1. main にチェックアウト
2. origin/main から pull
3. feature ブランチ作成
4. ステージング
5. コミット（Co-Authored-By 付き）
6. push
7. PR 作成

### 例

```bash
cd /Users/tanakee/Documents/development/hackathon/geekcamp1-20262-batON
./scripts/pr-setup.sh "feature/api-connection" "GraphQL API実装"
```

**結果：**
- ✅ feature/api-connection ブランチ作成
- ✅ すべてのファイルをコミット
- ✅ origin にpush
- ✅ PR #2 自動作成
