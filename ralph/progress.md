# Ralph Progress Tracker

> **Vision**: Comprehensive skill coverage for all Algorand development (excluding node operations)
> Last updated: 2026-01-14 (Iteration 8)
> Status: IN PROGRESS

## Current Task

**final-commit**: Final commit with summary of all changes

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

6. **create-use-algokit-utils**: Created new `use-algokit-utils` skill
   - Created SKILL.md with overview and core workflow
   - Created typescript/algorand-client.md with full TypeScript API documentation
   - Created python/algorand-client.md with full Python API documentation
   - Documented AlgorandClient initialization, accounts, transactions, groups
   - Included common patterns and amount helpers

7. **create-troubleshoot-errors**: Created new `troubleshoot-errors` skill
   - Created SKILL.md with error categories and quick diagnosis flow
   - Created contract-errors.md with logic errors, ABI errors, state errors, inner txn errors
   - Created transaction-errors.md with transaction, asset, account, and SDK errors
   - Included debugging tips and code examples for all error types

8. **PHASE 1 COMPLETE**: All remaining renames done manually
   - `building-smart-contracts` → `build-smart-contracts`
   - `algorand-typescript-rules` → `algorand-typescript`
   - `testing-smart-contracts` → `test-smart-contracts`
   - `calling-smart-contracts` → `call-smart-contracts`
   - `deploying-react-frontends` → `deploy-react-frontend`
   - `algokit-commands` → `use-algokit-cli`
   - `searching-algorand-examples` → `search-algorand-examples`
   - Updated all SKILL.md frontmatter and cross-references

9. **create-implement-arc-standards**: Created new `implement-arc-standards` skill
   - Created SKILL.md with overview of key ARCs for smart contract development
   - Created arc4-abi.md with comprehensive ARC-4 ABI documentation (types, encoding, method signatures)
   - Created arc32-arc56.md with app specification documentation (comparison, structure, usage)
   - Included code examples for both Python and TypeScript

10. **update-agents-md**: Updated AGENTS.md with new skill names and descriptions
    - Added `use-algokit-utils`, `troubleshoot-errors`, `implement-arc-standards` to Available Skills table
    - Updated table formatting for consistency

11. **update-readme**: Updated main README.md skill table
    - Added three new skills to the Skills table
    - Updated table formatting for consistency

12. **review-consistency**: Reviewed all skills for format consistency
    - Verified all 11 skills follow the standard format (frontmatter, sections, code examples)
    - Confirmed all skills have proper cross-references
    - No inconsistencies found requiring changes

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

- [x] **create-use-algokit-utils**: Create new `use-algokit-utils` skill
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

- [x] **create-troubleshoot-errors**: Create new `troubleshoot-errors` skill
  - Synthesize from existing skills and common issues
  - Create: skills/troubleshoot-errors/SKILL.md
  - Create: skills/troubleshoot-errors/contract-errors.md
  - Create: skills/troubleshoot-errors/transaction-errors.md

### PHASE 4: ARC STANDARDS (LOW PRIORITY) - COMPLETE

- [x] **create-implement-arc-standards**: Create new `implement-arc-standards` skill
  - Fetch: https://dev.algorand.co/reference/arc-standards/
  - Create: skills/implement-arc-standards/SKILL.md
  - Create: skills/implement-arc-standards/arc4-abi.md
  - Create: skills/implement-arc-standards/arc32-arc56.md

### PHASE 5: FINALIZATION

- [x] **update-agents-md**: Update AGENTS.md with new skill names and descriptions
- [x] **update-readme**: Update main README.md skill table with new names
- [x] **review-consistency**: Review all skills for format consistency
- [ ] **final-commit**: Final commit with summary of all changes

## Notes

(Add observations, blockers, or decisions here during execution)

---

## Iteration Log

### Iteration 8 (current)
- Started: 2026-01-14
- Task: update-agents-md, update-readme, review-consistency
- Result: Completed - updated AGENTS.md and README.md with three new skills (use-algokit-utils, troubleshoot-errors, implement-arc-standards); reviewed all 11 skills for format consistency and confirmed all follow the standard pattern

### Iteration 7
- Started: 2026-01-14
- Task: create-implement-arc-standards
- Result: Completed - created new `skills/implement-arc-standards/` skill with SKILL.md, arc4-abi.md, and arc32-arc56.md documenting ARC standards for smart contract development including ARC-4 ABI encoding, method signatures, app specifications, and typed client generation

### Iteration 6
- Started: 2026-01-14
- Task: create-troubleshoot-errors
- Result: Completed - created new `skills/troubleshoot-errors/` skill with SKILL.md, contract-errors.md, and transaction-errors.md documenting common error patterns, causes, and fixes for smart contracts, transactions, assets, and accounts

### Iteration 5
- Started: 2026-01-14
- Task: create-use-algokit-utils
- Result: Completed - created new `skills/use-algokit-utils/` skill with SKILL.md, typescript/algorand-client.md, and python/algorand-client.md documenting AlgorandClient API for both languages

### Iteration 4
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
