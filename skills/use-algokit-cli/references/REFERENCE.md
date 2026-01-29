# AlgoKit CLI Reference

Complete reference for AlgoKit CLI commands.

## Project Commands

### algokit project run build

Compile contracts and generate artifacts.

```bash
algokit project run build
```

**What it does:**
- Compiles contracts via Puya compiler
- Generates ARC-56 app specs (`*.arc56.json`)
- Creates typed client files
- Outputs to `artifacts/` directory

### algokit project run test

Run the test suite.

```bash
algokit project run test
```

**What it does:**
- Executes tests using Vitest
- Uses generated clients to interact with contracts
- Runs against localnet

### algokit project deploy

Deploy contracts to a network.

```bash
# Deploy to localnet
algokit project deploy localnet
```

**Prerequisites:**
- Localnet must be running
- Contracts must be built

## LocalNet Commands

### algokit localnet start

Start the local Algorand network.

```bash
algokit localnet start
```

**What it does:**
- Starts Docker containers for Algorand node
- Provides local development environment
- Includes KMD for test accounts

### algokit localnet stop

Stop the local network.

```bash
algokit localnet stop
```

### algokit localnet reset

Reset the network state.

```bash
algokit localnet reset
```

**Use when:**
- Need a clean slate
- State is corrupted
- Want to restart from genesis

### algokit localnet status

Check network status.

```bash
algokit localnet status
```

## Init Commands

### algokit init

Initialize a new project.

```bash
# TypeScript with Production preset
algokit init -n my-project -t typescript --answer preset_name production --defaults

# Python with Production preset
algokit init -n my-project -t python --answer preset_name production --defaults
```

**Options:**

| Flag | Description |
|------|-------------|
| `-n, --name` | Project name |
| `-t, --template` | Template: `typescript` or `python` |
| `--answer` | Answer template prompts |
| `--defaults` | Accept all defaults |
| `--no-git` | Skip git initialization |
| `--no-bootstrap` | Skip dependency installation |

## Project Configuration

### .algokit.toml

The `.algokit.toml` file configures project behavior:

```toml
[project]
type = "contract"
name = "my-project"
artifacts = "smart_contracts/artifacts"

[project.run]
build = "npm run build"
test = "npm run test"

[project.deploy]
command = "npm run deploy:ci"
environment_secrets = ["DEPLOYER_MNEMONIC"]

[project.deploy.localnet]
environment_secrets = []

[project.deploy.testnet]
environment_secrets = ["DEPLOYER_MNEMONIC"]
```

### Environment Files

Environment variables can be set in `.env` files:

- `.env` — Default values for all environments
- `.env.localnet` — LocalNet-specific overrides
- `.env.testnet` — TestNet-specific values
- `.env.mainnet` — MainNet-specific values

```bash
# .env.testnet
ALGOD_SERVER=https://testnet-api.algonode.cloud
ALGOD_PORT=443
ALGOD_TOKEN=
DEPLOYER_MNEMONIC="word1 word2 ..."
```

The `algokit project deploy` command automatically loads the appropriate `.env.{network}` file.

### Deploy Command Flags

```bash
# Deploy with specific deployer account
algokit project deploy testnet --deployer "DEPLOYER_NAME"

# Deploy with custom dispenser (for funding)
algokit project deploy testnet --dispenser "DISPENSER_NAME"
```

## Build Artifacts

After `algokit project run build`:

```
smart_contracts/
└── artifacts/
    └── <ContractName>/
        ├── <ContractName>.arc56.json    # ARC-56 app spec
        ├── <ContractName>.approval.teal  # Approval program
        ├── <ContractName>.clear.teal     # Clear program
        └── <ContractName>Client.ts       # Typed client
```

## Common Workflows

### Development Cycle

```bash
# 1. Write/edit contract code
# 2. Build
algokit project run build

# 3. Write/edit tests
# 4. Run tests
algokit project run test

# 5. Repeat until passing
```

### Deployment Workflow

```bash
# 1. Start localnet
algokit localnet start

# 2. Build contracts
algokit project run build

# 3. Deploy
algokit project deploy localnet
```

### Clean Start

```bash
# Reset everything
algokit localnet reset
algokit project run build
algokit project run test
```

## External Documentation

- [AlgoKit CLI Documentation](https://dev.algorand.co/algokit/cli/)
- [AlgoKit Project Commands](https://dev.algorand.co/reference/algokit-cli/#project)
- [AlgoKit LocalNet](https://dev.algorand.co/reference/algokit-cli/#localnet)
