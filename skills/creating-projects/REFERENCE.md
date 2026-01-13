# AlgoKit Init CLI Reference

## Templates

| Template     | Language   | Use Case                          |
| ------------ | ---------- | --------------------------------- |
| `typescript` | TypeScript | Production dApps, web integration |
| `python`     | Python     | Backend services, DeFi protocols  |

**Default:** `typescript`

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
algokit init -n <name> -t typescript --answer preset "Production" --answer author_name "<author>" --defaults

# Python (Production preset)
algokit init -n <name> -t python --answer preset "Production" --answer author_name "<author>" --defaults

# Skip git and bootstrap
algokit init -n <name> -t typescript --no-git --no-bootstrap --defaults

# Python with TypeScript deployment
algokit init -n <name> -t python --answer deployment_language "typescript" --defaults
```

## Options

| Flag                         | Description                        |
| ---------------------------- | ---------------------------------- |
| `-n, --name <name>`          | Project directory name (required)  |
| `-t, --template <name>`      | Template: `typescript` or `python` |
| `--answer "<key>" "<value>"` | Answer template prompts            |
| `--defaults`                 | Accept all defaults                |
| `--no-git`                   | Skip git initialization            |
| `--no-bootstrap`             | Skip dependency installation       |

## Full Reference

- [AlgoKit Init Command](https://dev.algorand.co/reference/algokit-cli/#init)
- [Template Options](https://dev.algorand.co/reference/algokit-cli/templates/)
