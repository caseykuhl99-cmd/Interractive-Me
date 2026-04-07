#!/bin/bash
# Test the GitHub Actions workflow locally using act

echo "=== Testing GitHub Actions Workflow Locally ==="
echo ""
echo "This script will run the workflow using 'act' to simulate GitHub Actions"
echo ""

# Check if act is installed
if ! command -v act &> /dev/null; then
    echo "❌ 'act' is not installed. Install it with:"
    echo "   curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash"
    exit 1
fi

echo "✓ 'act' is installed"
echo ""

# Check if .secrets file exists and has a real token
if [ ! -f .secrets ]; then
    echo "⚠️  .secrets file not found. Creating one..."
    echo "PROJECT_TOKEN=test_token_placeholder" > .secrets
fi

echo "📝 Make sure to add your real GitHub token to .secrets:"
echo "   PROJECT_TOKEN=ghp_your_actual_token"
echo ""
echo "⚠️  IMPORTANT: Token Requirements"
echo "   Your token needs these scopes:"
echo "   - repo (full control of repositories)"
echo "   - workflow (update GitHub Action workflows)"
echo "   - project (for GitHub Projects v2 integration)"
echo ""
echo "⚠️  WARNING: This will make REAL API calls!"
echo "   - It will try to create issues in JohnDeere-Tech/ETID-Innovation-AI"
echo "   - Issue #99 must exist as a project issue"
echo "   - This is simulating the workflow locally"
echo ""
echo "💡 RECOMMENDATION: Use test-github.sh instead to test with a real issue"
echo ""
read -p "Do you want to continue with act testing? (y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo "🚀 Running workflow with act..."
echo ""

# Run act with the issues event
act issues \
  --eventpath .github/workflows/test-event.json \
  --secret-file .secrets \
  --verbose

echo ""
echo "✅ Test complete!"
