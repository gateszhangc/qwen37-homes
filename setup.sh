#!/bin/bash
set -e

echo "=== Step 1: Check gh CLI ==="
if ! command -v gh &>/dev/null; then
  echo "gh CLI not found. Installing..."
  /bin/bash -c "$(curl -fsSL https://cli.github.com/install.sh)"
fi

echo ""
echo "=== Step 2: Check gh auth status ==="
AUTH_OUTPUT=$(gh auth status 2>&1) || true
echo "$AUTH_OUTPUT"

if echo "$AUTH_OUTPUT" | grep -q "Logged in to github.com as gateszhang92"; then
  echo "Already logged in as gateszhang92. Proceeding..."
elif echo "$AUTH_OUTPUT" | grep -qi "logged in"; then
  echo "Logged in but user may differ. Checking..."
  gh auth status --show-token 2>&1 | head -3
  echo ""
  echo "Please re-run: gh auth login"
  echo "And ensure you login as gateszhang92@gmail.com"
  exit 1
else
  echo "Not logged in or token expired."
  echo "Please run: gh auth login"
  echo "And login with gateszhang92@gmail.com"
  exit 1
fi

echo ""
echo "=== Step 3: Initialize git repo ==="
cd "$(dirname "$0")"
git init

echo ""
echo "=== Step 4: Create .gitignore ==="
cat > .gitignore << 'GITIGNORE'
# Dependencies
node_modules/

# Build output
dist/
build/
out/
*.tsbuildinfo

# OS files
.DS_Store
Thumbs.db
*.swp
*.swo
*~

# IDE
.idea/
.vscode/
*.sublime-*

# Logs
*.log
npm-debug.log*

# Env
.env
.env.local

# Temp
tmp/
temp/
GITIGNORE

echo ""
echo "=== Step 5: Create repo on GitHub ==="
gh repo create qwen37-homes --public --source=. --remote=origin --push 2>&1 || \
gh repo create qwen37-homes --public 2>&1

echo ""
echo "=== Step 6: Add & commit ==="
git add -A
git commit -m "Initial static site for codex cli" 2>/dev/null || echo "Nothing to commit"

echo ""
echo "=== Step 7: Push ==="
git branch -M main
git remote add origin https://github.com/gateszhang92/qwen37-homes.git 2>/dev/null || true
git push -u origin main 2>&1

echo ""
echo "=== Done ==="
echo "Repo URL: https://github.com/gateszhang92/qwen37-homes"
echo "Commit: $(git rev-parse HEAD)"
