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

**Default for smart contracts:** `typescript`

## Presets

### TypeScript

| Preset       | Description                  |
| ------------ | ---------------------------- |
| `Starter`    | Simple starting point        |
| `Production` | Tests, CI/CD, linting, audit |

### Python

| Preset       | Description                          |
| ------------ | ------------------------------------ |
| `Starter`    | Simple starting point                |
| `Production` | Tests, CI/CD, linting, type checking |

## Command Patterns

```bash
# TypeScript (Production preset)
algokit init -n <name> -t typescript --answer preset_name production --answer author_name "<author>" --defaults

# Python (Production preset)
algokit init -n <name> -t python --answer preset_name production --answer author_name "<author>" --defaults

# Skip git and bootstrap
algokit init -n <name> -t typescript --no-git --no-bootstrap --defaults

# Python with TypeScript deployment
algokit init -n <name> -t python --answer deployment_language "typescript" --defaults
```

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
