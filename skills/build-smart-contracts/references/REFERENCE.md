# Algorand Development Workflow

Follow this exact order when building smart contracts.

## Step 1: Search Documentation

Use `search_algorand_knowledge_sources` for conceptual guidance, best practices, and official documentation.

If no results: proceed with caution, explain limitations, use known patterns.

## Step 2: Retrieve Canonical Examples

Use GitHub tools to get code from these repositories in priority order:

### Priority 1: DevPortal Code Examples
`algorandfoundation/devportal-code-examples`
- TypeScript: `projects/typescript-examples/contracts/`
- Python: `projects/python-examples/contracts/`
- Always include corresponding test files

### Priority 2: Puya Compiler Examples
- TypeScript: `algorandfoundation/puya-ts` → `examples/`
- Python: `algorandfoundation/puya` → `examples/`
- Examples: hello_world_arc4, voting, amm

### Priority 3: AlgoKit Templates
- `algorandfoundation/algokit-typescript-template`
- `algorandfoundation/algokit-python-template`

### Priority 4: AlgoKit Utilities
- `algorandfoundation/algokit-cli`
- `algorandfoundation/algokit-client-generator-ts`
- `algorandfoundation/algokit-utils-ts`

## Step 3: Pattern-Specific Lookups

For specific patterns, search these locations:

### Box Storage
- TypeScript: `devportal-code-examples/projects/typescript-examples/contracts/BoxStorage/`
- Python: `puya/examples/voting/` or `puya/examples/amm/` (BoxMap patterns)

### Common Patterns
State management, ABI methods, inner transactions: Start in `contracts/` subdirectories of Priority 1 repos.

## Step 4: Generate Code

- Carefully adapt canonical examples
- Preserve all safety checks and efficient patterns
- Follow all critical rules from the algorand-typescript skill

## Step 5: Include Tests

- Always include or suggest integration tests
- Use generated clients for testing contracts
- Only include unit tests if explicitly requested by user

## Step 6: Build and Test

```bash
algokit project run build   # Compile contracts
algokit project run test    # Run tests
```

Iterate on fixes if compilation errors or test failures occur.

### Key Points

- **Use CLI for deployment**: `algokit project deploy localnet` handles large app specs
- **Use `methodSignature` for calls**: Simpler than passing full app spec
- **Get App ID from deployment output**: Required for all MCP calls
