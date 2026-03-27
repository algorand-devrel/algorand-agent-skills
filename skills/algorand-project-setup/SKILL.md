---
name: algorand-project-setup
description: Scaffolds Algorand projects using AlgoKit CLI, manages LocalNet, and retrieves code examples from official GitHub repositories. Use when initializing projects with algokit init, running build/test/deploy commands, starting or resetting LocalNet, or searching for Algorand contract examples and patterns.
---

# AlgoKit Project Setup & Examples

## Quick Start

```bash
# Install AlgoKit
pipx install algokit

# Create a fullstack project — smart contracts + React frontend (default)
algokit init -n my-project -t fullstack --answer preset_name production --answer contract_template typescript --defaults

# Development cycle
cd my-project
algokit project run build    # Compile contracts
algokit project run test     # Run tests
algokit localnet start       # Start local network
algokit project deploy localnet  # Deploy
```

## Reference Guide

### Creating Projects

Initialize new Algorand projects using AlgoKit templates and presets.

- [project-templates.md](./references/project-templates.md) — Templates, presets, CLI flags, and customization options

### CLI Commands

Build, test, deploy, and manage LocalNet with AlgoKit CLI.

- [cli-commands.md](./references/cli-commands.md) — Full CLI command reference and workflow

### Searching Examples

Find working contract examples from Algorand Foundation repositories using GitHub tools.

- [github-search-tools.md](./references/github-search-tools.md) — GitHub MCP tools, priority repos, search patterns

## Important Rules

- **Always confirm with user** before running `algokit init`
- **Default to fullstack template (`-t fullstack`)** with TypeScript contracts and production preset — **MUST** pass `--answer contract_template typescript` since the default is Python
- **Always build before testing** — tests use generated clients
- **Search algorandfoundation repos first** — official, vetted examples

## Canonical Example Repos

| Repository | Best For |
|------------|----------|
| `algorandfoundation/devportal-code-examples` | Beginner-friendly contract examples (TypeScript + Python) |
| `algorandfoundation/puya-ts` | Advanced TypeScript contract examples |
| `algorandfoundation/puya` | Advanced Python contract examples |
| `algorandfoundation/algokit-fullstack-template` | Fullstack project template (contracts + React) |

Always fetch corresponding test files alongside contract examples.

## Cross-References

- **`algorand-core`** — AVM mental model, transaction types, protocol concepts
- **`algorand-typescript`** / **`algorand-python`** — Contract development syntax and patterns
- **`algorand-frontend`** — React frontend integration and wallet connection
