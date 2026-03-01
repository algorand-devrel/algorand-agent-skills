# AlgoKit Init CLI Reference (Python)

## Python Presets

| Preset       | Description                          |
| ------------ | ------------------------------------ |
| `Starter`    | Simple starting point                |
| `Production` | Tests, CI/CD, linting, type checking |

## Command Patterns

```bash
# Python (Production preset)
algokit init -n <name> -t python --answer preset_name production --answer author_name "<author>" --defaults

# Python (Starter preset)
algokit init -n <name> -t python --answer author_name "<author>" --defaults

# Python with TypeScript deployment scripts
algokit init -n <name> -t python --answer deployment_language "typescript" --defaults

# Skip git and bootstrap
algokit init -n <name> -t python --no-git --no-bootstrap --defaults
```

## Options

| Flag                         | Description                                      |
| ---------------------------- | ------------------------------------------------ |
| `-n, --name <name>`          | Project directory name (required)                |
| `-t, --template python`      | Python template (required)                       |
| `--answer "<key>" "<value>"` | Answer template prompts                          |
| `--defaults`                 | Accept all defaults                              |
| `--no-git`                   | Skip git initialization                          |
| `--no-bootstrap`             | Skip dependency installation                     |
| `--workspace`                | Create within workspace structure (default)      |
| `--no-workspace`             | Create standalone project                        |

## Deployment Language Option

Python projects support an optional `deployment_language` answer to control what language is used for deployment scripts:

| Value        | Description                                |
| ------------ | ------------------------------------------ |
| `python`     | Python deployment scripts (default)        |
| `typescript` | TypeScript deployment scripts              |

```bash
algokit init -n <name> -t python --answer deployment_language "typescript" --defaults
```

## Full Reference

- [AlgoKit Init Command](https://dev.algorand.co/reference/algokit-cli/#init)
- [AlgoKit Templates](https://dev.algorand.co/algokit/official-algokit-templates/)
