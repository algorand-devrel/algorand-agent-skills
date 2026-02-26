# AlgoKit Init CLI Reference (TypeScript)

## TypeScript Presets

| Preset       | Description                  |
| ------------ | ---------------------------- |
| `Starter`    | Simple starting point        |
| `Production` | Tests, CI/CD, linting, audit |

## TypeScript Templates

| Template     | Use Case                                      |
| ------------ | --------------------------------------------- |
| `typescript` | Smart contracts (Algorand TypeScript/PuyaTs)  |
| `react`      | Frontend dApp with wallet integration         |
| `fullstack`  | Smart contracts + React frontend combined     |

## Command Patterns

```bash
# TypeScript (Production preset)
algokit init -n <name> -t typescript --answer preset_name production --answer author_name "<author>" --defaults

# TypeScript (Starter preset)
algokit init -n <name> -t typescript --answer author_name "<author>" --defaults

# React frontend
algokit init -n <name> -t react --defaults

# Fullstack (contracts + React frontend)
algokit init -n <name> -t fullstack --defaults

# Skip git and bootstrap
algokit init -n <name> -t typescript --no-git --no-bootstrap --defaults
```

## Options

| Flag                         | Description                                      |
| ---------------------------- | ------------------------------------------------ |
| `-n, --name <name>`          | Project directory name (required)                |
| `-t, --template <name>`      | Template name (`typescript`, `react`, `fullstack`)|
| `--answer "<key>" "<value>"` | Answer template prompts                          |
| `--defaults`                 | Accept all defaults                              |
| `--no-git`                   | Skip git initialization                          |
| `--no-bootstrap`             | Skip dependency installation                     |
| `--workspace`                | Create within workspace structure (default)      |
| `--no-workspace`             | Create standalone project                        |

## Full Reference

- [AlgoKit Init Command](https://dev.algorand.co/reference/algokit-cli/#init)
- [AlgoKit Templates](https://dev.algorand.co/algokit/official-algokit-templates/)
