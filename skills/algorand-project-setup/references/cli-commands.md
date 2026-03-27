# AlgoKit CLI Reference

Complete reference for AlgoKit CLI commands.

## Contents

- [Project Commands](#project-commands)
- [LocalNet Commands](#localnet-commands)
- [Generate Commands](#generate-commands)
- [Init Commands](#init-commands)
- [Project Configuration](#project-configuration)
- [Build Artifacts](#build-artifacts)
- [Common Workflows](#common-workflows)
- [Utility Commands](#utility-commands)
- [External Documentation](#external-documentation)

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

### algokit project link

Automatically invoke `algokit generate client` on contract projects in the workspace. Must be run from the root of a standalone `frontend` typed project.

```bash
# Link all contract projects with the frontend
algokit project link --all

# Link specific contract project(s)
algokit project link --project-name my-contracts

# In fullstack template workspaces, this is already configured — running build handles linking
algokit project run build
```

**Key flags:**

| Flag | Description |
|------|-------------|
| `-p, --project-name` | Specify contract project(s) to link (repeatable) |
| `-a, --all` | Link all contract projects in workspace |
| `-l, --language` | Generated client language: `typescript` (default) or `python` |
| `-f, --fail-fast` | Exit immediately if any client generation fails |

**Use when:** frontend needs typed clients from contracts in a fullstack workspace. Template projects handle this automatically via `algokit project run build`.

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

## Generate Commands

### algokit generate client

Generate typed app clients from ARC-56 or ARC-32 application spec files.

```bash
# Generate TypeScript client
algokit generate client -o smart_contracts/artifacts/MyContract/MyContractClient.ts smart_contracts/artifacts/MyContract/MyContract.arc56.json

# Generate Python client
algokit generate client -o smart_contracts/artifacts/MyContract/my_contract_client.py --language python smart_contracts/artifacts/MyContract/MyContract.arc56.json
```

**Key flags:**

| Flag | Description |
|------|-------------|
| `-o, --output` | Output file path for generated client |
| `-l, --language` | Output language: `typescript` (default) or `python` |
| `-v, --version` | Pin to a specific client generator version (e.g., `1.2.3`) |
| `APP_SPEC_PATH` | Path to ARC-56/ARC-32 JSON spec (positional argument) |

**Note:** In template projects, `algokit project run build` automatically compiles contracts **and** generates typed clients — you rarely need to run this command manually.

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
| `-t, --template` | Template: `fullstack`, `typescript`, `python`, `react`, `tealscript`, `base` |
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

## Utility Commands

### algokit doctor

Check AlgoKit installation health and dependency versions.

```bash
algokit doctor
```

**What it does:**
- Verifies AlgoKit, Docker, Python, Node.js, and other dependency versions
- Reports missing or outdated tools
- Use as a first step when debugging CLI issues

### algokit explore

Open the Lora blockchain explorer for the active network.

```bash
# Open explorer (defaults to LocalNet if running)
algokit explore
```

**What it does:**
- Opens Lora (https://lora.algokit.io) in the browser
- Connects to LocalNet, TestNet, or MainNet depending on configuration
- Useful for inspecting transactions, accounts, and application state

## External Documentation

- [AlgoKit CLI Documentation](https://dev.algorand.co/algokit/cli/)
- [AlgoKit Project Commands](https://dev.algorand.co/reference/algokit-cli/#project)
- [AlgoKit LocalNet](https://dev.algorand.co/reference/algokit-cli/#localnet)
