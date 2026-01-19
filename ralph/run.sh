#!/bin/bash

# Ralph Loop - Iterative Claude Workflow Pattern
# Each iteration runs Claude in fresh context (non-interactive mode with -p flag)
# See README.md for documentation

cd "$(dirname "$0")/.."

MAX_ITERATIONS=${1:-50}

echo "Starting Ralph loop (max $MAX_ITERATIONS iterations)"
echo "Press Ctrl+C to stop"
echo ""

for ((i=1; i<=$MAX_ITERATIONS; i++)); do
    echo "=== Iteration $i / $MAX_ITERATIONS ==="

    # Run Claude with -p flag for non-interactive mode (fresh context each time)
    result=$(claude -p "$(cat ralph/prompt.md)" --dangerously-skip-permissions --output-format text 2>&1) || true

    echo "$result"

    # Check for completion in output (supports both generic and legacy signals)
    if [[ "$result" == *"WORKFLOW_COMPLETE"* ]] || [[ "$result" == *"SKILLS_COMPLETE"* ]]; then
        echo ""
        echo "=== Workflow complete! ==="
        exit 0
    fi

    echo ""
    echo "--- End of iteration $i ---"
    echo ""
    sleep 3
done

echo ""
echo "=== Max iterations ($MAX_ITERATIONS) reached ==="
echo "Check ralph/progress.md for current state"
