# Ralph Progress Tracker

> **Vision**: Comprehensive skill coverage for all Algorand development (excluding node operations)
> Last updated: 2026-01-14 (Iteration 4)
> Status: IN PROGRESS

## Current Task

**create-use-algokit-utils**: Create new `use-algokit-utils` skill with TypeScript and Python documentation

## Completed Tasks

1. **rename-creating-projects**: Renamed `creating-projects` → `create-project`
   - Renamed directory using `git mv`
   - Updated SKILL.md frontmatter `name` field
   - Updated references in: examples/multi-skill-workflow.md, README.md, setups/AGENTS.md

2. **add-python-types**: Created `build-smart-contracts/python/types.md`
   - Documented all AVM types: UInt64, Bytes, String, BigUInt
   - Documented reference types: Account, Asset, Application
   - Added CORRECT/INCORRECT code examples
   - Included type comparison tables and common mistakes

3. **add-python-storage**: Created `build-smart-contracts/python/storage.md`
   - Documented GlobalState patterns (simple and wrapper)
   - Documented LocalState with opt-in requirements
   - Documented Box, BoxMap, BoxRef for large data
   - Included MBR formulas and funding patterns
   - Added common mistakes and storage comparison table

4. **add-python-decorators**: Created `build-smart-contracts/python/decorators.md`
   - Documented @arc4.abimethod with all parameters (create, allow_actions, readonly, name, default_args)
   - Documented @arc4.baremethod for bare methods
   - Documented @subroutine with inline parameter
   - Included lifecycle methods (__init__, clear_state_program)
   - Added method visibility summary table and common mistakes

5. **add-python-transactions**: Created `build-smart-contracts/python/transactions.md`
   - Documented inner transactions (itxn): Payment, AssetTransfer, AssetConfig, ApplicationCall
   - Documented grouped inner transactions with itxn.submit_txns()
   - Documented group transactions (gtxn) as ABI parameters and by index
   - Included fee pooling security pattern (always fee=0)
   - Added inner transaction result properties tables
   - Added common mistakes and security considerations

6. **PHASE 1 COMPLETE**: All remaining renames done manually
   - `building-smart-contracts` → `build-smart-contracts`
   - `algorand-typescript-rules` → `algorand-typescript`
   - `testing-smart-contracts` → `test-smart-contracts`
   - `calling-smart-contracts` → `call-smart-contracts`
   - `deploying-react-frontends` → `deploy-react-frontend`
   - `algokit-commands` → `use-algokit-cli`
   - `searching-algorand-examples` → `search-algorand-examples`
   - Updated all SKILL.md frontmatter and cross-references

## Queue

### PHASE 1: RENAME EXISTING SKILLS (HIGH PRIORITY) - COMPLETE

All skills renamed to action-oriented names following Anthropic best practices.

- [x] **rename-creating-projects**: `creating-projects` → `create-project`
- [x] **rename-building-smart-contracts**: `building-smart-contracts` → `build-smart-contracts`
- [x] **rename-algorand-typescript-rules**: `algorand-typescript-rules` → `algorand-typescript`
- [x] **rename-testing-smart-contracts**: `testing-smart-contracts` → `test-smart-contracts`
- [x] **rename-calling-smart-contracts**: `calling-smart-contracts` → `call-smart-contracts`
- [x] **rename-deploying-react-frontends**: `deploying-react-frontends` → `deploy-react-frontend`
- [x] **rename-algokit-commands**: `algokit-commands` → `use-algokit-cli`
- [x] **rename-searching-algorand-examples**: `searching-algorand-examples` → `search-algorand-examples`

### PHASE 2: ADD PYTHON CONTRACT PATTERNS (HIGH PRIORITY)

Add Python-specific syntax patterns to `build-smart-contracts` skill.

- [x] **add-python-types**: Create `build-smart-contracts/python/types.md`
  - Fetch: https://dev.algorand.co/concepts/smart-contracts/languages/python/
  - Cover: algopy types (UInt64, Bytes, String, etc.)
  - Include CORRECT/INCORRECT examples

- [x] **add-python-storage**: Create `build-smart-contracts/python/storage.md`
  - Cover: GlobalState, LocalState, BoxMap patterns
  - Include MBR considerations

- [x] **add-python-decorators**: Create `build-smart-contracts/python/decorators.md`
  - Cover: @arc4.abimethod, @subroutine, @arc4.baremethod
  - Include method visibility patterns

- [x] **add-python-transactions**: Create `build-smart-contracts/python/transactions.md`
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

### Iteration 4 (current)
- Started: 2026-01-14
- Task: add-python-transactions
- Result: Completed - created `skills/build-smart-contracts/python/transactions.md` with inner transactions (itxn), grouped inner transactions, group transactions (gtxn), fee pooling patterns, and common mistakes

### Iteration 3
- Started: 2026-01-14
- Task: add-python-decorators
- Result: Completed - created `skills/build-smart-contracts/python/decorators.md` with @arc4.abimethod, @arc4.baremethod, @subroutine documentation including method visibility patterns, lifecycle methods, and common mistakes

### Iteration 2
- Started: 2026-01-14
- Task: add-python-storage
- Result: Completed - created `skills/build-smart-contracts/python/storage.md` with GlobalState, LocalState, Box, BoxMap, BoxRef documentation including MBR formulas, funding patterns, and common mistakes

### Iteration 1
- Started: 2026-01-14
- Task: add-python-types
- Result: Completed - created `skills/build-smart-contracts/python/types.md` with comprehensive Algorand Python type system documentation including UInt64, Bytes, String, BigUInt, Account, Asset, Application types with CORRECT/INCORRECT examples

### Iteration 0 (pre-iteration)
- Started: 2026-01-14
- Task: rename-creating-projects + manual renames
- Result: Completed - renamed all skills to action-oriented names
