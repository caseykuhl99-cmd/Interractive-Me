# Project Skeleton Workflow

This workflow automatically creates a structured hierarchy of issues when a new "Project" issue is created.

## How It Works

1. **Trigger**: When an issue with the `project` label is created
2. **Creates**: Phase issues (P1-P9, PR) as sub-issues of the Project
3. **Creates**: Task issues for certain phases (P1, P2, P3, P4, P7, P9)
4. **Updates**: Parent-child relationships in GitHub Projects v2
5. **Adds**: Checklists to Project and Phase issues

## Required Setup

### 1. GitHub Token Permissions

The `PROJECT_TOKEN` secret must have the following permissions:

#### For Personal Access Token (Classic):
- `repo` - Full control of private repositories
- `project` - Full control of projects
- `write:org` - Write access to organization (if applicable)

#### For Fine-Grained Personal Access Token:
- Repository permissions:
  - Issues: Read and write
  - Contents: Read-only
- Organization permissions (if using organization projects):
  - Projects: Read and write

### 2. Set the Secret

Add the token as a repository or organization secret named `PROJECT_TOKEN`:

```bash
# Using GitHub CLI
gh secret set PROJECT_TOKEN --body "YOUR_TOKEN_HERE"

# Or in GitHub UI: Settings → Secrets and variables → Actions → New repository secret
```

### 3. Project Configuration

The workflow is configured to use Project #604. To change this:
- Edit line 88 in `project-skeleton.yml`
- Change `PROJECT_NUMBER="604"` to your project number

### 4. Project v2 Requirements

Your project must have:
- A custom field named "Parent" (type: Issue) for parent-child relationships
- This field is used to link Tasks → Phases → Project

## Testing

### Option 1: Syntax Validation (Safest - No API Calls)
```bash
./test-dry-run.sh
```
Validates bash syntax and logic without making any real API calls.

### Option 2: GitHub Live Test (Recommended)
```bash
./test-github.sh
```
Creates a real test project issue in GitHub, which triggers the workflow automatically. This is the most accurate test of the actual workflow behavior.

**Requirements:**
- Authenticated with GitHub CLI (`gh auth login`)
- Push access to the repository
- `PROJECT_TOKEN` secret must be set in the repository

### Option 3: Local with `act` (Advanced)
```bash
# 1. Add your token to .secrets
# 2. Create issue #99 as a test project issue
# 3. Run the test
./test-workflow.sh
```
**Note:** This simulates GitHub Actions locally but requires Docker and may have limitations.

### Manual Testing on GitHub
```bash
# Push the workflow
git add .github/workflows/project-skeleton.yml
git commit -m "Add project skeleton workflow"
git push

# Create a test issue with the project label
gh issue create \
  --title "[TEST] My Test Project" \
  --body "Test project description" \
  --label "project"
```

## Workflow Structure

```
Project Issue (#X)
├── [Phase] P1 - Charter Creation (#X+1)
│   ├── [Task] P1.1 - Insight: Reach out to idea submitter...
│   ├── [Task] P1.2 - Insight: Document the charter...
│   └── [Task] P1.3 - Insight: Set up meeting with I&S team...
├── [Phase] P2 - Insight Gathering (#X+2)
│   ├── [Task] P2.1 - Insight: Reach out to focus group...
│   └── [Task] P2.2 - Insight: Document the info...
├── [Phase] P3 - Insight Review (#X+3)
│   └── ... (3 tasks)
└── ... (10 phases total)
```

## Troubleshooting

### "Resource not accessible by personal access token"
- Your token doesn't have sufficient permissions
- Ensure token has `project` scope (for classic tokens)
- For organization projects, ensure organization access is granted

### "Could not find project #604"
- The project number is incorrect
- Your token doesn't have access to the project
- The project is in a different organization/user account

### Issues created but no parent relationships
- Project doesn't have a "Parent" field
- Add a custom field named "Parent" (type: Issue) to your project

### Issues not added to project
- Token lacks project write permissions
- Project is archived or read-only
- Project belongs to a different organization than the repository

## Modifying the Workflow

### Change Phase Definitions
Edit lines 54-64 in `project-skeleton.yml` to modify the standard phases.

### Change Task Definitions
Edit lines 70-76 in `project-skeleton.yml` to modify tasks for each phase.

### Change Labels
Edit lines 38-44 in `project-skeleton.yml` to modify label names and colors.

## Support

If you encounter issues, check:
1. GitHub Actions logs for detailed error messages
2. Token permissions in GitHub settings
3. Project field configuration (must have "Parent" field)
4. Organization settings (may restrict project access)
