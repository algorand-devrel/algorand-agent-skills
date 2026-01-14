# Ralph Progress Tracker

> **Vision**: Comprehensive skill coverage for all Algorand development (excluding node operations)
> Last updated: Iteration 1
> Status: IN PROGRESS

## Current Task

**rename-building-smart-contracts**: Rename `building-smart-contracts` → `build-smart-contracts`

## Completed Tasks

1. **rename-creating-projects**: Renamed `creating-projects` → `create-project`
   - Renamed directory using `git mv`
   - Updated SKILL.md frontmatter `name` field
   - Updated references in: examples/multi-skill-workflow.md, README.md, setups/AGENTS.md

## Queue

### PHASE 1: RENAME EXISTING SKILLS (HIGH PRIORITY)

Rename all skills to action-oriented names following Anthropic best practices.

- [x] **rename-creating-projects**: Rename `creating-projects` → `create-project`
  - Rename directory
  - Update SKILL.md frontmatter `name` field
  - Update any internal references

- [ ] **rename-building-smart-contracts**: Rename `building-smart-contracts` → `build-smart-contracts`
  - Rename directory
  - Update SKILL.md frontmatter `name` field
  - Update any internal references

- [ ] **rename-algorand-typescript-rules**: Rename `algorand-typescript-rules` → `algorand-typescript`
  - Rename directory
  - Update SKILL.md frontmatter `name` field
  - Update references in other skills

- [ ] **rename-testing-smart-contracts**: Rename `testing-smart-contracts` → `test-smart-contracts`
  - Rename directory
  - Update SKILL.md frontmatter `name` field
  - Update any internal references

- [ ] **rename-calling-smart-contracts**: Rename `calling-smart-contracts` → `call-smart-contracts`
  - Rename directory
  - Update SKILL.md frontmatter `name` field
  - Update any internal references

- [ ] **rename-deploying-react-frontends**: Rename `deploying-react-frontends` → `deploy-react-frontend`
  - Rename directory
  - Update SKILL.md frontmatter `name` field
  - Update any internal references

- [ ] **rename-algokit-commands**: Rename `algokit-commands` → `use-algokit-cli`
  - Rename directory
  - Update SKILL.md frontmatter `name` field
  - Update any internal references

- [ ] **rename-searching-algorand-examples**: Rename `searching-algorand-examples` → `search-algorand-examples`
  - Rename directory
  - Update SKILL.md frontmatter `name` field
  - Update any internal references

### PHASE 2: ADD PYTHON CONTRACT PATTERNS (HIGH PRIORITY)

Add Python-specific syntax patterns to `build-smart-contracts` skill.

- [ ] **add-python-types**: Create `build-smart-contracts/python/types.md`
  - Fetch: https://dev.algorand.co/concepts/smart-contracts/languages/python/
  - Cover: algopy types (UInt64, Bytes, String, etc.)
  - Include CORRECT/INCORRECT examples

- [ ] **add-python-storage**: Create `build-smart-contracts/python/storage.md`
  - Cover: GlobalState, LocalState, BoxMap patterns
  - Include MBR considerations

- [ ] **add-python-decorators**: Create `build-smart-contracts/python/decorators.md`
  - Cover: @arc4.abimethod, @subroutine, @arc4.baremethod
  - Include method visibility patterns

- [ ] **add-python-transactions**: Create `build-smart-contracts/python/transactions.md`
  - Cover: Inner transactions, group transactions
  - Include CORRECT/INCORRECT examples

### PHASE 3: CREATE NEW SKILLS (MEDIUM PRIORITY)

- [ ] **create-use-algokit-utils**: Create new `use-algokit-utils` skill
  - Fetch: https://dev.algorand.co/algokit/utils/typescript/overview/
  - Fetch: https://dev.algorand.co/algokit/utils/python/overview/
  - Create: skills/use-algokit-utils/SKILL.md
  - Structure:
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

- [ ] **create-troubleshoot-errors**: Create new `troubleshoot-errors` skill
  - Synthesize from existing skills and common issues
  - Create: skills/troubleshoot-errors/SKILL.md
  - Create: skills/troubleshoot-errors/contract-errors.md
  - Create: skills/troubleshoot-errors/transaction-errors.md
  - Create: skills/troubleshoot-errors/account-errors.md

### PHASE 4: ARC STANDARDS (LOW PRIORITY)

- [ ] **create-implement-arc-standards**: Create new `implement-arc-standards` skill
  - Fetch: https://dev.algorand.co/reference/arc-standards/
  - Create: skills/implement-arc-standards/SKILL.md
  - Create: skills/implement-arc-standards/arc4-abi.md
  - Create: skills/implement-arc-standards/arc32-arc56.md

### PHASE 5: FINALIZATION

- [ ] **update-agents-md**: Update AGENTS.md with new skill names and descriptions
- [ ] **update-readme**: Update main README.md skill table with new names
- [ ] **review-consistency**: Review all skills for format consistency
- [ ] **final-commit**: Final commit with summary of all changes

## Notes

(Add observations, blockers, or decisions here during execution)

---

## Iteration Log

### Iteration 1
- Started: 2026-01-14
- Task: rename-creating-projects
- Result: Completed - renamed directory, updated frontmatter, updated 5 references in 3 files
