#!/bin/bash

# Check if a commit message was provided
if [ -z "$1" ]; then
  echo "❌ Error: You must provide a commit message."
  echo "Usage: ./script/deploy.sh \"Your commit message\""
  exit 1
fi

# Build Hugo site with minify
echo "🚧 Building site..."
hugo --minify

# Git add, commit, and push
echo "📦 Committing and pushing to Git..."
git add .
git commit -m "$1"
git push

echo "✅ Deploy complete!"

