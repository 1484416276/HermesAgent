#!/bin/bash
# publish_to_github.sh - Script to initialize and push HermesAgent to GitHub

set -e

echo "========================================"
echo "  HermesAgent GitHub Publisher"
echo "========================================"
echo ""

# Check if git is available
if ! command -v git &> /dev/null; then
    echo "❌ Git is required but not installed."
    exit 1
fi

# Check if we're in the right directory
if [ ! -f "Package.swift" ] || [ ! -d "HermesAgent" ]; then
    echo "❌ Please run this script from the HermesAgent project root."
    exit 1
fi

# Get GitHub username
if [ -z "$1" ]; then
    read -p "Enter your GitHub username: " GITHUB_USERNAME
else
    GITHUB_USERNAME="$1"
fi

REPO_NAME="HermesAgent"
REPO_URL="https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"

echo ""
echo "Repository: $REPO_URL"
echo ""

# Confirm action
read -p "Initialize git repository and create GitHub repo? (y/N): " CONFIRM
if [[ ! $CONFIRM =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

# Initialize git if not already done
if [ ! -d ".git" ]; then
    echo "📦 Initializing git repository..."
    git init
    git add -A
    git commit -m "chore: initial project structure for HermesAgent"
    echo "✅ Git repository initialized"
else
    echo "✅ Git repository already exists"
fi

# Create GitHub repository using gh CLI if available
if command -v gh &> /dev/null; then
    echo ""
    echo "🐙 Creating GitHub repository..."
    
    # Check if already logged in to gh
    if gh auth status &> /dev/null; then
        # Create repo if it doesn't exist
        if ! gh repo view "$GITHUB_USERNAME/$REPO_NAME" &> /dev/null; then
            gh repo create "$REPO_NAME" --public --description "A sophisticated iPad AI Agent application inspired by Claude Code and Hermès design philosophy" --source=. --remote=origin --push
            echo "✅ GitHub repository created and code pushed"
        else
            echo "⚠️  Repository already exists on GitHub"
            git remote remove origin 2>/dev/null || true
            git remote add origin "$REPO_URL"
            git branch -M main
            git push -u origin main || echo "⚠️  Push failed. You may need to set up authentication."
        fi
    else
        echo "⚠️  GitHub CLI not authenticated. Please run: gh auth login"
        echo "Then manually add remote: git remote add origin $REPO_URL"
    fi
else
    echo ""
    echo "⚠️  GitHub CLI (gh) not found."
    echo "Please manually create the repository:"
    echo "  1. Go to https://github.com/new"
    echo "  2. Repository name: $REPO_NAME"
    echo "  3. Make it public"
    echo "  4. Don't initialize with README"
    echo ""
    echo "Then run these commands:"
    echo "  git remote add origin $REPO_URL"
    echo "  git branch -M main"
    echo "  git push -u origin main"
fi

echo ""
echo "========================================"
echo "  🎉 Setup Complete!"
echo "========================================"
echo ""
echo "Next steps:"
echo "  1. Visit your repo: $REPO_URL"
echo "  2. Update README.md with your info"
echo "  3. Add screenshots to the repo"
echo "  4. Enable GitHub Actions in repo settings"
echo "  5. Add topics: ios, swift, swiftui, ipad, ai, claude, agent"
echo ""
echo "Happy coding! 🦋"