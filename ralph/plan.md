# Ralph Workflow Plan Template

<!-- ============================================================
     [CUSTOMIZE] Use this template to plan your Ralph workflow.
     This file is optional but recommended for complex workflows.
     ============================================================ -->

## Vision & Scope

**Goal**: [CUSTOMIZE: What is the end state you want to achieve?]

### In Scope

<!-- [CUSTOMIZE] What will this workflow cover? -->

| Domain | Description |
|--------|-------------|
| **Area 1** | What's included |
| **Area 2** | What's included |
| **Area 3** | What's included |

### Out of Scope

<!-- [CUSTOMIZE] What will this workflow NOT cover? -->

| Domain | Reason |
|--------|--------|
| **Area X** | Why it's excluded |
| **Area Y** | Why it's excluded |

---

## Architecture

<!-- [CUSTOMIZE] Describe the structure of artifacts you'll create/modify -->

### Design Principles

1. **Principle 1**: Description
2. **Principle 2**: Description
3. **Principle 3**: Description

### Artifact Structure

<!-- Example structure - customize for your workflow -->

```
output/
├── category-a/
│   ├── item-1/
│   │   ├── main-file.md
│   │   └── details/
│   └── item-2/
│       └── main-file.md
├── category-b/
│   └── item-3/
│       └── main-file.md
└── shared/
    └── templates/
```

### Naming Convention

```
{type}-{subject}[-{qualifier}]

Examples:
- create-user
- validate-input
- process-data-batch
```

---

## Gap Analysis

<!-- [CUSTOMIZE] Compare current state to desired state -->

### Current State

| Item | Status | Notes |
|------|--------|-------|
| Item 1 | Exists | May need updates |
| Item 2 | Missing | Needs creation |
| Item 3 | Partial | Needs completion |

### Work Required

<!-- [CUSTOMIZE] List what needs to be created or modified -->

#### High Priority

1. **Work item 1**: Why it's important and what's needed
2. **Work item 2**: Why it's important and what's needed

#### Medium Priority

3. **Work item 3**: Description
4. **Work item 4**: Description

#### Low Priority

5. **Work item 5**: Description

---

## Quality Standards

<!-- [CUSTOMIZE] Define quality criteria for artifacts -->

### Format Requirements

```markdown
---
metadata: value
---

# Title

## Required Section 1

Content...

## Required Section 2

Content...
```

### Content Guidelines

- **Guideline 1**: Description
- **Guideline 2**: Description
- **Guideline 3**: Description

### Anti-Patterns to Avoid

- Don't do X because Y
- Don't do A because B
- Avoid C when D

---

## Execution

### Phases

```
PHASE A: [Name]
├── Task 1: Description
├── Task 2: Description
└── Task 3: Description

PHASE B: [Name]
├── Task 4: Description
└── Task 5: Description

PHASE C: [Name]
├── Task 6: Description
└── Final review
```

### Safety Limits

- **Max iterations**: 50 (adjust based on task count)
- **Max file size**: 500 lines (split if larger)
- **Commit frequency**: After each task completion

### To Run

```bash
cd /path/to/project
./ralph/run.sh          # Default iterations
./ralph/run.sh 100      # Custom limit
```

---

## Success Criteria

<!-- [CUSTOMIZE] How will you know the workflow is complete? -->

After completion:
- [ ] Criterion 1: Description
- [ ] Criterion 2: Description
- [ ] Criterion 3: Description
- [ ] Criterion 4: Description
- [ ] All items pass quality review
