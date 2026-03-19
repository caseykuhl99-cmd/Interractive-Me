#!/bin/bash
# Test the workflow by creating a real project issue in GitHub

echo "=== GitHub Actions Workflow Test (Real Issue) ==="
echo ""

# Check if gh is installed
if ! command -v gh &> /dev/null; then
    echo "❌ 'gh' (GitHub CLI) is not installed"
    exit 1
fi

echo "✓ GitHub CLI is installed"
echo ""

# Check authentication
if ! gh auth status &> /dev/null; then
    echo "❌ Not authenticated with GitHub CLI"
    echo "Run: gh auth login"
    exit 1
fi

echo "✓ Authenticated with GitHub"
echo ""

REPO="JohnDeere-Tech/ETID-Innovation-AI"

echo "📋 This will create a REAL test project issue in: $REPO"
echo ""
echo "⚠️  The workflow will then create Phase and Task issues automatically"
echo ""
read -p "Do you want to continue? (y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo "🚀 Creating test project issue..."

# Create a test project issue with the project label
ISSUE_URL=$(gh issue create \
  --repo "$REPO" \
  --title "[TEST] Workflow Test Project - $(date +%Y%m%d-%H%M%S)" \
  --body "This is a test project issue created to test the GitHub Actions workflow.

## Test Details
- Created: $(date)
- Purpose: Testing automated phase and task creation
- Expected: 10 phase issues and multiple task issues should be created automatically

**You can safely close this issue and all related issues after testing.**" \
  --label "project" 2>&1)

if [[ "$ISSUE_URL" == *"http"* ]]; then
    ISSUE_NUM=$(echo "$ISSUE_URL" | grep -oP '[0-9]+$')
    echo ""
    echo "✅ Created test project issue #$ISSUE_NUM"
    echo "   URL: $ISSUE_URL"
    echo ""
    echo "🔄 The GitHub Actions workflow should now be running..."
    echo "   Check: https://github.com/$REPO/actions"
    echo ""
    echo "⏳ Waiting 5 seconds, then checking workflow status..."
    sleep 5
    
    # Try to get the workflow run status
    echo ""
    gh run list --repo "$REPO" --limit 3 --workflow=project-skeleton.yml
    echo ""
    echo "💡 To watch the workflow live, run:"
    echo "   gh run watch --repo $REPO"
    echo ""
    echo "To clean up test issues later:"
    echo "   gh issue list --repo $REPO --label project --state all"
else
    echo "❌ Failed to create issue: $ISSUE_URL"
    exit 1
fi
