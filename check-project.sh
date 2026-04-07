#!/bin/bash
# Check if GitHub Project #604 has a Parent field configured

echo "=== Checking Project #604 Configuration ==="
echo ""

# Check if gh is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is not installed"
    exit 1
fi

# Load token from .secrets file if it exists
if [ -f .secrets ]; then
    source .secrets
fi

if [ -z "$PROJECT_TOKEN" ]; then
    echo "⚠️  PROJECT_TOKEN not found in .secrets, using gh CLI default auth"
    echo ""
fi

REPO_OWNER="JohnDeere-Tech"
PROJECT_NUMBER="604"

echo "Fetching project information..."
echo ""

# Get project fields (use PROJECT_TOKEN if available)
if [ -n "$PROJECT_TOKEN" ]; then
    export GH_TOKEN="$PROJECT_TOKEN"
    echo "Using token from .secrets"
else
    echo "Using gh CLI authentication"
fi
echo ""

PROJECT_DATA=$(gh api graphql -f query='
  query($owner: String!, $number: Int!) {
    organization(login: $owner) {
      projectV2(number: $number) {
        id
        title
        fields(first: 50) {
          nodes {
            ... on ProjectV2FieldCommon {
              id
              name
              dataType
            }
          }
        }
      }
    }
  }' -f owner="$REPO_OWNER" -F number="$PROJECT_NUMBER" 2>&1)

# Check if query succeeded
if [[ "$PROJECT_DATA" == *"error"* ]] || [[ "$PROJECT_DATA" == *"Error"* ]]; then
    echo "❌ Error fetching project data:"
    echo "$PROJECT_DATA"
    echo ""
    echo "Make sure:"
    echo "  1. Project #604 exists"
    echo "  2. Your GitHub token has project read permissions"
    echo "  3. You have access to the JohnDeere-Tech organization"
    exit 1
fi

PROJECT_ID=$(echo "$PROJECT_DATA" | jq -r '.data.organization.projectV2.id // empty')
PROJECT_TITLE=$(echo "$PROJECT_DATA" | jq -r '.data.organization.projectV2.title // "Unknown"')

if [ -z "$PROJECT_ID" ] || [ "$PROJECT_ID" = "null" ]; then
    echo "❌ Project #604 not found in organization: $REPO_OWNER"
    exit 1
fi

echo "✅ Found Project #604: $PROJECT_TITLE"
echo "   Project ID: $PROJECT_ID"
echo ""

echo "Available fields in the project:"
echo ""

# Get detailed field information
echo "$PROJECT_DATA" | jq -r '.data.organization.projectV2.fields.nodes | .[]' > /tmp/fields_debug.json

# Show all fields with their types
echo "$PROJECT_DATA" | jq -r '.data.organization.projectV2.fields.nodes | .[] | "  - \(.name) (Type: \(.dataType // "N/A"))"'

echo ""
echo "Checking for Parent fields (debug info):"
echo "$PROJECT_DATA" | jq '.data.organization.projectV2.fields.nodes | .[] | select(.name | contains("arent"))'

PARENT_FIELD_ID=$(echo "$PROJECT_DATA" | jq -r '.data.organization.projectV2.fields.nodes | .[] | select(.name == "Parent issue" or .name == "Parent") | .id')
PARENT_FIELD_NAME=$(echo "$PROJECT_DATA" | jq -r '.data.organization.projectV2.fields.nodes | .[] | select(.name == "Parent issue" or .name == "Parent") | .name')
PARENT_FIELD_TYPE=$(echo "$PROJECT_DATA" | jq -r '.data.organization.projectV2.fields.nodes | .[] | select(.name == "Parent issue" or .name == "Parent") | .dataType')

echo ""

if [ -n "$PARENT_FIELD_ID" ] && [ "$PARENT_FIELD_ID" != "null" ]; then
    echo "✅ Parent field found: $PARENT_FIELD_NAME"
    echo "   Field ID: $PARENT_FIELD_ID"
    echo "   Field Type: $PARENT_FIELD_TYPE"
    echo ""
    
    if [ "$PARENT_FIELD_TYPE" = "PARENT_ISSUE" ]; then
        echo "⚠️  IMPORTANT: PARENT_ISSUE fields are READ-ONLY"
        echo "   They are automatically populated by GitHub based on issue sub-tasks"
        echo "   You cannot set them via the API"
        echo ""
        echo "   To create parent-child relationships:"
        echo "   1. Use task lists in issue descriptions with #issue syntax"
        echo "   2. Or convert issues to sub-issues in the GitHub UI"
        echo "   3. The Parent issue field will auto-populate when relationships exist"
    else
        echo "The workflow can create parent-child relationships in this project."
    fi
else
    echo "❌ Parent field NOT found!"
    echo ""
    echo "To add a Parent field to Project #604:"
    echo "  1. Go to: https://github.com/orgs/$REPO_OWNER/projects/$PROJECT_NUMBER"
    echo "  2. Click the '+' button to add a new field"
    echo "  3. Select 'Issue' as the field type"
    echo "  4. Name it: Parent issue (or Parent)"
    echo "  5. Save the field"
    echo ""
    echo "After adding the field, run the workflow again."
fi

echo ""
echo "=== Summary ==="
if [ -n "$PARENT_FIELD_ID" ] && [ "$PARENT_FIELD_ID" != "null" ]; then
    echo "✅ Project configuration is ready for parent-child relationships"
else
    echo "⚠️  Parent field is missing - relationships will not be created"
fi
