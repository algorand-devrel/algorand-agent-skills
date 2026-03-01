# Building Smart Contracts

Create modern Algorand smart contracts in Algorand TypeScript (PuyaTs) or Algorand Python (PuyaPy) -- statically-typed subsets compiled to TEAL bytecode by the Puya compiler.

## Core Workflow

1. **Search documentation** for concepts and best practices
2. **Retrieve canonical examples** from priority repositories
3. **Generate code** adapting examples to requirements
4. **Include integration tests** using generated clients
5. **Build and test** with AlgoKit commands

## How to Proceed

1. **Search documentation first:**
   - Use `kapa_search_algorand_knowledge_sources` MCP tool for conceptual guidance
   - If MCP unavailable, use web search: `site:dev.algorand.co {concept}`
   - If no results, proceed with caution using known patterns

2. **Retrieve canonical examples:**
   - Priority 1: `algorandfoundation/devportal-code-examples`
   - Priority 2: `algorandfoundation/puya-ts` (TypeScript) or `algorandfoundation/puya` (Python)
   - Priority 3: `algorandfoundation/algokit-typescript-template` or `algorandfoundation/algokit-python-template`
   - Always include corresponding test files

3. **Generate code:**
   - Choose TypeScript or Python based on user preference
   - Adapt examples carefully, preserving safety checks
   - Follow syntax rules from the language-specific skill (`algorand-typescript` or `algorand-python`)

4. **Include tests:**
   - Always include or suggest integration tests
   - Use generated clients for testing contracts

5. **Build and test:**
   ```bash
   algokit project run build   # Compile contracts
   algokit project run test    # Run tests
   ```

## Important Rules

- **NEVER use PyTEAL or Beaker** -- these are legacy, superseded by Puya
- **NEVER write raw TEAL** -- always use Algorand TypeScript or Algorand Python
- **NEVER import external libraries** into contract code
- **Always search docs first** before writing code
- **Always retrieve examples** from priority repositories

## References

- [Detailed Workflow](./build-smart-contracts-reference.md)
