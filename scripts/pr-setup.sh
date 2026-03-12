#!/bin/bash

# pr-setup: Create feature branch, commit, and open PR
# Usage: ./scripts/pr-setup.sh "feature/branch-name" "PR Title" "Optional PR description"

set -e

FEATURE_NAME=$1
PR_TITLE=$2
PR_BODY=$3

# Validate inputs
if [ -z "$FEATURE_NAME" ]; then
    echo "❌ Error: Feature name required"
    echo "Usage: ./scripts/pr-setup.sh \"feature/branch-name\" \"PR Title\" [description]"
    exit 1
fi

# Convert branch name to PR title if not provided
if [ -z "$PR_TITLE" ]; then
    PR_TITLE=$(echo "$FEATURE_NAME" | sed 's/feature\///' | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++)$i=toupper(substr($i,1,1))substr($i,2)}1')
fi

echo "🚀 Starting PR setup for: $FEATURE_NAME"
echo ""

# 1. Make sure we're on main
echo "📍 Checking out main..."
git checkout main
git pull origin main

# 2. Create feature branch
echo "🌿 Creating feature branch: $FEATURE_NAME"
git checkout -b "$FEATURE_NAME"

# 3. Stage all changes
echo "📦 Staging changes..."
git add .

# 4. Show what will be committed
echo ""
echo "📋 Changes to commit:"
git status --short
echo ""

# 5. Create commit
COMMIT_MESSAGE=$(cat <<COMMIT_EOF
feat: $PR_TITLE

Co-Authored-By: Claude Haiku 4.5 <noreply@anthropic.com>
COMMIT_EOF
)

echo "💾 Creating commit..."
git commit -m "$COMMIT_MESSAGE"

# 6. Push to origin
echo "🔼 Pushing to origin..."
git push origin "$FEATURE_NAME"

# 7. Open PR
echo "📮 Creating pull request..."
if [ -z "$PR_BODY" ]; then
    gh pr create \
        --title "feat: $PR_TITLE" \
        --base main \
        --head "$FEATURE_NAME" \
        --body "## Summary

- 実装内容をここに記述

🤖 Generated with [Claude Code](https://claude.com/claude-code)"
else
    gh pr create \
        --title "feat: $PR_TITLE" \
        --base main \
        --head "$FEATURE_NAME" \
        --body "$PR_BODY"
fi

echo ""
echo "✅ PR setup complete!"
echo "📌 Feature branch: $FEATURE_NAME"
