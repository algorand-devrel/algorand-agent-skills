# Ralph Workflow Plan: Algorand Agent Skills Enhancement

## Vision & Scope

**Goal**: Comprehensive skill coverage for virtually all Algorand development (excluding node operations), enabling AI coding assistants to build complete applications on Algorand.

### In Scope

| Domain | Skills |
|--------|--------|
| **Smart Contracts** | TypeScript (PuyaTs), Python (PuyaPy) syntax, patterns, testing |
| **Client Applications** | AlgoKit Utils for TypeScript and Python |
| **Tooling** | AlgoKit CLI commands and workflows |
| **Core Concepts** | Accounts, transactions, assets, MBR, opt-ins (integrated into relevant skills) |
| **Standards** | ARC specs for interoperability |
| **Debugging** | Common errors and solutions |
| **Frontend** | React dApp patterns |

### Out of Scope

| Domain | Reason |
|--------|--------|
| **Node Operations** | Running, configuring, maintaining nodes |
| **Indexer Setup** | Infrastructure deployment |
| **Network Administration** | Consensus, participation, network-level concerns |

---

## Skill Architecture

### Design Principles

Following [Anthropic's Agent Skills Best Practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices):

1. **Action-oriented names**: Use imperative verbs (`build-`, `test-`, `use-`)
2. **Progressive disclosure**: SKILL.md < 500 lines, detailed content in sub-files
3. **Concise content**: Assume Claude is smart; only add what Claude doesn't know
4. **Domain organization**: Sub-directories by language/topic, loaded only when needed
5. **No redundancy**: Single skills with sub-files, not parallel skills per language

### Naming Convention

```
{action}-{target}[-{qualifier}]

Examples:
- build-smart-contracts
- test-smart-contracts
- use-algokit-utils
- troubleshoot-errors
```

**Format requirements**:
- Lowercase letters, numbers, hyphens only
- Max 64 characters
- No reserved words (anthropic, claude)

### Skill Categories

Aligned with [Algorand Developer Documentation](https://dev.algorand.co/):

```
skills/
├── Getting Started
│   └── create-project          # Initialize AlgoKit projects
│
├── Smart Contracts (Concepts + Build)
│   ├── build-smart-contracts   # Write contracts (TS + Python)
│   │   ├── SKILL.md            # Workflow overview
│   │   ├── typescript/         # TS-specific patterns
│   │   └── python/             # Python-specific patterns (NEW)
│   │
│   ├── algorand-typescript     # TypeScript syntax reference
│   │   ├── SKILL.md            # Core rules
│   │   ├── types-and-values.md
│   │   ├── storage.md
│   │   ├── methods-and-abi.md
│   │   └── transactions.md
│   │
│   ├── test-smart-contracts    # Contract testing
│   │   ├── SKILL.md
│   │   ├── typescript/         # TS test patterns
│   │   └── python/             # Python test patterns (NEW)
│   │
│   └── call-smart-contracts    # Deploy and interact
│       ├── SKILL.md
│       └── REFERENCE.md
│
├── Client Applications (AlgoKit Utils)
│   └── use-algokit-utils       # Client-side patterns (NEW)
│       ├── SKILL.md            # Overview + when to use
│       ├── typescript/         # TS client patterns
│       │   ├── algorand-client.md
│       │   ├── accounts.md     # Includes MBR, keys concepts
│       │   ├── transactions.md
│       │   └── assets.md       # Includes opt-in concepts
│       └── python/             # Python client patterns
│           ├── algorand-client.md
│           ├── accounts.md
│           ├── transactions.md
│           └── assets.md
│
├── Tooling
│   └── use-algokit-cli         # CLI commands
│       ├── SKILL.md
│       └── REFERENCE.md
│
├── Debugging
│   └── troubleshoot-errors     # Common errors (NEW)
│       ├── SKILL.md
│       ├── contract-errors.md
│       ├── transaction-errors.md
│       └── account-errors.md
│
├── Standards
│   └── implement-arc-standards # ARC compliance (NEW)
│       ├── SKILL.md
│       ├── arc4-abi.md
│       └── arc32-arc56.md
│
├── Frontend
│   └── deploy-react-frontend   # React dApp patterns
│       ├── SKILL.md
│       ├── REFERENCE.md
│       └── EXAMPLES.md
│
└── Meta
    └── search-algorand-examples # Find canonical examples
        ├── SKILL.md
        └── REFERENCE.md
```

---

## Gap Analysis

### Current Skills (8) - Require Renaming

| Current Name | New Name | Status |
|--------------|----------|--------|
| `creating-projects` | `create-project` | Rename |
| `building-smart-contracts` | `build-smart-contracts` | Rename + add Python sub-dir |
| `algorand-typescript-rules` | `algorand-typescript` | Rename |
| `testing-smart-contracts` | `test-smart-contracts` | Rename |
| `calling-smart-contracts` | `call-smart-contracts` | Rename |
| `deploying-react-frontends` | `deploy-react-frontend` | Rename |
| `algokit-commands` | `use-algokit-cli` | Rename |
| `searching-algorand-examples` | `search-algorand-examples` | Rename |

### New Skills to Create

#### 1. Python patterns in `build-smart-contracts` (HIGH PRIORITY)

**Why**: Python is equally supported but has no syntax guide.

**What LLMs get wrong**:
- Using standard Python types instead of algopy types (`int` vs `UInt64`)
- Incorrect decorator usage (`@arc4.abimethod` vs `@subroutine`)
- Missing `clone()` equivalent patterns
- State management differences from TypeScript

**Doc sources**:
- https://dev.algorand.co/concepts/smart-contracts/languages/python/
- https://github.com/algorandfoundation/puya (examples/)

**Files to create**:
```
build-smart-contracts/python/
├── types.md
├── storage.md
├── decorators.md
└── transactions.md
```

#### 2. `use-algokit-utils` (MEDIUM PRIORITY)

**Why**: Client-side patterns are scattered across skills; need consolidated guidance.

**What LLMs get wrong**:
- AlgorandClient initialization for different networks
- Account creation and management patterns
- Proper payment/transfer patterns
- Reading chain state correctly
- Async/sync API differences between TS and Python

**Doc sources**:
- https://dev.algorand.co/algokit/utils/typescript/overview/
- https://dev.algorand.co/algokit/utils/typescript/algorand-client/
- https://dev.algorand.co/algokit/utils/python/overview/
- https://dev.algorand.co/algokit/utils/python/algorand-client/

**Files to create**:
```
use-algokit-utils/
├── SKILL.md
├── typescript/
│   ├── algorand-client.md
│   ├── accounts.md
│   ├── transactions.md
│   └── assets.md
└── python/
    ├── algorand-client.md
    ├── accounts.md
    ├── transactions.md
    └── assets.md
```

#### 3. `troubleshoot-errors` (MEDIUM PRIORITY)

**Why**: Proactive error prevention is more valuable than reactive debugging.

**Common errors to cover**:
- "Balance below minimum" - not funding accounts/apps for MBR
- "Asset not found" - forgetting opt-in
- "Logic eval error" - various causes
- Box reference errors
- Transaction group errors

**Doc sources**:
- Synthesized from existing skills + common issues

**Files to create**:
```
troubleshoot-errors/
├── SKILL.md
├── contract-errors.md
├── transaction-errors.md
└── account-errors.md
```

#### 4. `implement-arc-standards` (LOW PRIORITY)

**Why**: Important for interoperability but less frequently needed.

**Topics**:
- ARC-4 (ABI)
- ARC-32/ARC-56 (App specs)
- ARC-3/ARC-69 (NFT metadata)

**Doc sources**:
- https://dev.algorand.co/reference/arc-standards/

**Files to create**:
```
implement-arc-standards/
├── SKILL.md
├── arc4-abi.md
└── arc32-arc56.md
```

---

## Quality Standards

### SKILL.md Format (Required)

```markdown
---
name: skill-name
description: Third-person description of what this skill does. Use when [triggers].
---

# Skill Title

## When to use this skill

- Bullet points of use cases
- **Strong triggers:** phrases that activate this skill

## Overview / Core Workflow

1. Numbered steps (high-level)

## How to proceed

Detailed instructions with code examples

## Important Rules / Guidelines

Tables and code examples with CORRECT/INCORRECT

## Common Variations / Edge Cases

| Scenario | Approach |
|----------|----------|

## References / Further Reading

- Links to sub-files and related skills
```

### Description Field (Critical for Discovery)

The description enables skill selection from 100+ available skills. Must include:
1. **What** the skill does (third person)
2. **When** to use it (triggers)

**Good example**:
```yaml
description: Build Algorand smart contracts using TypeScript or Python. Use when creating contracts, writing contract code, or asking about Algorand development patterns.
```

**Bad example**:
```yaml
description: Helps with contracts
```

### Code Examples (Required)

```typescript
// CORRECT - Brief explanation
const amount: uint64 = Uint64(20)

// INCORRECT - Why this fails
const amount = 20  // Error: JavaScript number not allowed in AVM
```

### What NOT To Include

- Time-sensitive information (use "old patterns" section if needed)
- Vague instructions Claude already knows
- PyTEAL, Beaker, or raw TEAL patterns (deprecated)
- Files > 500 lines (split into sub-files)
- Deeply nested references (keep one level deep from SKILL.md)

---

## Execution

### Ralph Workflow

```
┌─────────────────────────────────────────────────────────────┐
│ 1. Read progress.md to understand current state             │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. Pick next task from QUEUE (priority order)               │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│ 3. Fetch documentation via WebFetch (or WebSearch fallback) │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│ 4. Create/update skill files following standards            │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│ 5. Update progress.md with what was done                    │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│ 6. Git commit changes with descriptive message              │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│ 7. QUEUE empty? → output "SKILLS_COMPLETE"                  │
│    Otherwise → continue to next iteration                   │
└─────────────────────────────────────────────────────────────┘
```

### Safety Limits

- **Max iterations**: 25
- **Max lines per file**: 500
- **Commit frequency**: Every skill completion

### To Run

```bash
cd /home/gabe/Code/@algorand-devrel/algorand-agent-skills
./ralph/run.sh          # Default: 20 iterations
./ralph/run.sh 50       # Custom limit
```

---

## Success Metrics

After completion:
- [ ] All 8 existing skills renamed to action-oriented names
- [ ] Python patterns added to `build-smart-contracts`
- [ ] `use-algokit-utils` skill created with TS + Python
- [ ] `troubleshoot-errors` skill created
- [ ] `implement-arc-standards` skill created
- [ ] All skills follow Anthropic best practices format
- [ ] All skills have CORRECT/INCORRECT examples
- [ ] AGENTS.md updated with new skill names
- [ ] README.md updated with new skill descriptions
