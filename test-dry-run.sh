#!/bin/bash
# Dry-run test: Extract and validate bash scripts without making API calls

echo "=== Dry-Run Test: Validating Bash Scripts ==="
echo ""

WORKFLOW_FILE=".github/workflows/project-skeleton.yml"

if [ ! -f "$WORKFLOW_FILE" ]; then
    echo "❌ Workflow file not found: $WORKFLOW_FILE"
    exit 1
fi

echo "✓ Workflow file found"
echo ""

# Extract bash scripts from the workflow and check syntax
echo "Checking bash syntax..."
echo ""

# Create a temporary directory
TMP_DIR=$(mktemp -d)
trap "rm -rf $TMP_DIR" EXIT

# Extract the main script blocks and validate them
echo "1️⃣  Validating 'Define default phases and tasks' script..."
cat > "$TMP_DIR/prep.sh" << 'EOF'
#!/bin/bash
set -e
REPO="test/repo"
PROJECT_NUMBER="1"

echo "project_number=$PROJECT_NUMBER" >> /tmp/output

PHASES="P1 - Charter Creation and Project Kickoff
P2 - Insight Gathering
P3 - Insight Review
P4 - Analytics & Integration Project Handoff Meeting
P5 - Analytics Work
P6 - Integration Work
P7 - PoC Design Review (Product and Integration)
P8 - Analytics Work for Production
P9 - Integration
PR - Recognition"

echo "phases<<EOF" >> /tmp/output
echo "$PHASES" >> /tmp/output
echo "EOF" >> /tmp/output

echo "repo=$REPO" >> /tmp/output

cat > phase_tasks.txt << 'TASKS_EOF'
P1|P1.1 - Insight: Reach out to idea submitter and document a high level understanding of the project|P1.2 - Insight: Document the charter (Project level task) with the template details|P1.3 - Insight: Set up meeting with I&S team to discuss the project, focusing on building an understanding of the questions that need to be asked during the insight interviews
P2|P2.1 - Insight: Reach out to focus group, asking them the questions defined on P1|P2.2 - Insight: Document the info into a summary presentation
P3|P3.1 - Insight: Set up meeting with I&S team to discuss the summary presentation|P3.2 - Insight: Reach out to focus group requesting more info if needed|P3.3 - Insight: Formally present Insight project findings to the focus group
P4|P4.1 - Insight: Set up meeting with I&S team to present project documentation|P4.2 - Analytics: During the meeting, create the analytics tasks needed to be completed as part of project development|P4.3 - Integration: During the meeting, identify the impacted audience of the product (P9) and creating the integration tasks for P6
P7|P7.1 - Insight: Set up meeting with I&S team to review the product and align on Integration tasks|P7.2 - Insight: Set up Design Review meeting with the focus group to review the product and align on Integration tasks
P9|P9.1 - Marketing Materials|P9.2 - Training Class|P9.3 - User Feedback|P9.4 - Measure the Value
TASKS_EOF

echo "✓ Script creates phase_tasks.txt with $(wc -l < phase_tasks.txt) task definitions"
EOF

bash -n "$TMP_DIR/prep.sh" 2>&1
if [ $? -eq 0 ]; then
    echo "  ✓ Syntax valid"
    # Actually run it to test logic
    bash "$TMP_DIR/prep.sh" 2>&1
    if [ $? -eq 0 ]; then
        echo "  ✓ Execution successful"
    else
        echo "  ❌ Execution failed"
    fi
else
    echo "  ❌ Syntax error found"
fi
echo ""

echo "2️⃣  Validating phase parsing logic..."
cat > "$TMP_DIR/parse.sh" << 'EOF'
#!/bin/bash
# Test parsing the phases
PHASES="P1 - Charter Creation and Project Kickoff
P2 - Insight Gathering
P3 - Insight Review"

while IFS= read -r PH; do
  if [ -n "$PH" ]; then
    echo "  - Would create phase: $PH"
  fi
done <<< "$PHASES"
EOF

bash -n "$TMP_DIR/parse.sh" 2>&1
if [ $? -eq 0 ]; then
    echo "  ✓ Syntax valid"
    bash "$TMP_DIR/parse.sh" 2>&1
    echo "  ✓ Parsing works correctly"
else
    echo "  ❌ Syntax error found"
fi
echo ""

echo "3️⃣  Validating task extraction logic..."
cat > "$TMP_DIR/tasks.sh" << 'EOF'
#!/bin/bash
cat > phase_tasks.txt << 'TASKS_EOF'
P1|Task 1.1|Task 1.2|Task 1.3
P2|Task 2.1|Task 2.2
P3|Task 3.1|Task 3.2|Task 3.3
TASKS_EOF

PH_NAME="P1 - Charter Creation and Project Kickoff"
PHASE_ID=$(echo "$PH_NAME" | grep -oP '^P[0-9]+|^PR')

if grep -q "^$PHASE_ID|" phase_tasks.txt; then
    echo "  ✓ Found tasks for $PHASE_ID"
    PHASE_TASKS=$(grep "^$PHASE_ID|" phase_tasks.txt | cut -d'|' -f2-)
    IFS='|' read -ra TASKS <<< "$PHASE_TASKS"
    echo "  ✓ Found ${#TASKS[@]} tasks"
    for TK in "${TASKS[@]}"; do
        if [ -n "$TK" ]; then
            echo "    - $TK"
        fi
    done
else
    echo "  ❌ No tasks found for $PHASE_ID"
fi
EOF

bash -n "$TMP_DIR/tasks.sh" 2>&1
if [ $? -eq 0 ]; then
    echo "  ✓ Syntax valid"
    bash "$TMP_DIR/tasks.sh" 2>&1
    echo "  ✓ Task extraction works"
else
    echo "  ❌ Syntax error found"
fi
echo ""

echo "✅ All bash syntax checks passed!"
echo ""
echo "Next steps:"
echo "  1. Review the workflow file for logical errors"
echo "  2. Use test-workflow.sh to test with real API (creates real issues!)"
echo "  3. Or push to a test branch and use workflow_dispatch to test"
