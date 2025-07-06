#!/bin/bash

# Setup script for otaku.lt-sdk Terraform project
# This script sets up environment variables for secure GitHub authentication

set -e

echo "🔧 Setting up otaku.lt-sdk Terraform environment..."

# Check if gh CLI is installed and authenticated
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is not installed"
    echo "   Install with: brew install gh"
    exit 1
fi

# Check if user is authenticated with gh
if ! gh auth status &> /dev/null; then
    echo "❌ Not authenticated with GitHub CLI"
    echo "   Run: gh auth login"
    exit 1
fi

# Export GitHub token from gh CLI
export GITHUB_TOKEN="$(gh auth token)"
export GITHUB_OWNER="otaku-lt"

echo "✅ Environment variables set:"
echo "   GITHUB_TOKEN: ${GITHUB_TOKEN:0:7}... (hidden)"
echo "   GITHUB_OWNER: $GITHUB_OWNER"

echo ""
echo "🚀 Ready to run Terraform commands!"
echo "   terraform plan"
echo "   terraform apply"
echo ""
echo "💡 To persist these variables in your shell, add to your ~/.zshrc or ~/.bashrc:"
echo "   export GITHUB_TOKEN=\"\$(gh auth token)\""
echo "   export GITHUB_OWNER=\"otaku-lt\""
