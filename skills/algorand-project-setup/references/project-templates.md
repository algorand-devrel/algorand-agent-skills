# AlgoKit Init CLI Reference

## Templates

| Template     | Language   | Use Case                                      |
| ------------ | ---------- | --------------------------------------------- |
| `typescript` | TypeScript | Smart contracts (Algorand TypeScript/PuyaTs)  |
| `python`     | Python     | Smart contracts (Algorand Python/PuyaPy)      |
| `tealscript` | TypeScript | Smart contracts (TealScript - alternative)    |
| `react`      | TypeScript | Frontend dApp with wallet integration         |
| `fullstack`  | Both       | Smart contracts + React frontend combined     |
| `base`       | N/A        | Minimal workspace template                    |

**Default template:** `fullstack` (smart contracts + React frontend with TypeScript)

## Presets

### TypeScript

| Preset       | Description                                  |
| ------------ | -------------------------------------------- |
| `Starter`    | Simple starting point                        |
| `Production` | Tests, CI/CD, linting, audit                 |
| `Custom`     | Choose individual options (testing, CI, etc.) |

### Python

| Preset       | Description                                  |
| ------------ | -------------------------------------------- |
| `Starter`    | Simple starting point                        |
| `Production` | Tests, CI/CD, linting, type checking         |
| `Custom`     | Choose individual options (testing, CI, etc.) |

## Command Patterns

```bash
# Fullstack — TypeScript contracts + React frontend (default)
algokit init -n <name> -t fullstack --answer preset_name production --answer contract_template typescript --defaults

# Fullstack — Python contracts + React frontend
algokit init -n <name> -t fullstack --answer preset_name production --answer contract_template python --defaults

# Smart contracts only — TypeScript (Production preset)
algokit init -n <name> -t typescript --answer preset_name production --answer author_name "<author>" --defaults

# Smart contracts only — Python (Production preset)
algokit init -n <name> -t python --answer preset_name production --answer author_name "<author>" --defaults

# Frontend only — React dApp
algokit init -n <name> -t react --defaults

# Skip git and bootstrap
algokit init -n <name> -t fullstack --answer contract_template typescript --no-git --no-bootstrap --defaults
```

## Fullstack Workspace Structure

The `fullstack` template creates a workspace with sub-projects:

```
<project-name>/
├── projects/
│   ├── <project-name>-contracts/   # Smart contract sub-project
│   │   ├── smart_contracts/        # Contract source code
│   │   └── tests/                  # Contract tests
│   └── <project-name>-frontend/    # React frontend sub-project
│       ├── src/                    # React app source
│       └── public/
├── .algokit.toml                   # Workspace config
└── README.md
```

Both sub-projects share a single workspace and can be built/tested together via `algokit project run` commands from the root.

## Fullstack Template Answer Keys

These are the exact `--answer` keys accepted by the fullstack template (from its `copier.yaml`):

| Key                  | Type   | Values                                  | Default    |
| -------------------- | ------ | --------------------------------------- | ---------- |
| `contract_template`  | str    | `typescript`, `python`, `tealscript`    | `python`   |
| `preset_name`        | str    | `starter`, `production`, `custom`       | `starter`  |
| `contract_name`      | str    | snake_case (python) or PascalCase (ts)  | `hello_world` |
| `author_name`        | str    | Any                                     | `Your-Name` |
| `author_email`       | str    | Any                                     | `your@email.tld` |
| `deployment_language`| str    | `python`, `typescript` (python contracts only) | `python` |

**IMPORTANT:** The contract language key is `contract_template`, NOT `contract` or `frontend`. The default is `python`, so you **must** pass `--answer contract_template typescript` to get TypeScript contracts.

## Options

| Flag                         | Description                                      |
| ---------------------------- | ------------------------------------------------ |
| `-n, --name <name>`          | Project directory name (required)                |
| `-t, --template <name>`      | Template name (see Templates table above)        |
| `--answer "<key>" "<value>"` | Answer template prompts                          |
| `--defaults`                 | Accept all defaults                              |
| `--no-git`                   | Skip git initialization                          |
| `--no-bootstrap`             | Skip dependency installation                     |
| `--workspace`                | Create within workspace structure (default)      |
| `--no-workspace`             | Create standalone project                        |
| `--ide` / `--no-ide`         | Open IDE after creation (default: auto-detect)   |

## Initialize from Examples

AlgoKit can also initialize projects from pre-built examples:

```bash
# Interactive example selector
algokit init example

# List available examples
algokit init example --list

# Initialize specific example
algokit init example <example_id>
```

## Full Reference

- [AlgoKit Init Command](https://dev.algorand.co/reference/algokit-cli/#init)
- [AlgoKit Templates](https://dev.algorand.co/algokit/official-algokit-templates/)
