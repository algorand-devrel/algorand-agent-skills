#!/bin/bash

# Ralph Loop for Algorand Agent Skills
# Simple bash loop that runs Claude iteratively until completion

set -e

cd "$(dirname "$0")/.."

MAX_ITERATIONS=${1:-20}
ITERATION=0

echo "Starting Ralph loop (max $MAX_ITERATIONS iterations)"
echo "Press Ctrl+C to stop"
echo ""

while [ $ITERATION -lt $MAX_ITERATIONS ]; do
    ITERATION=$((ITERATION + 1))
    echo "=== Iteration $ITERATION / $MAX_ITERATIONS ==="

    # Run Claude with the prompt
    claude --dangerously-skip-permissions \
        "Read ralph/prompt.md and execute the skill enhancement workflow.
         This is iteration $ITERATION of $MAX_ITERATIONS.
         Output SKILLS_COMPLETE (exactly) when all tasks are done."

    # Check for completion marker in the output or progress file
    if grep -q "SKILLS_COMPLETE" ralph/progress.md 2>/dev/null; then
        echo ""
        echo "=== SKILLS_COMPLETE found - workflow finished! ==="
        exit 0
    fi

    echo ""
    echo "Iteration $ITERATION complete. Continuing in 3 seconds..."
    sleep 3
done

echo ""
echo "=== Max iterations ($MAX_ITERATIONS) reached ==="
echo "Check ralph/progress.md for current state"
