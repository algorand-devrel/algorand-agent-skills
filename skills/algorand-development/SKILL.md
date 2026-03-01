---
name: algorand-development
description: Comprehensive guide for Algorand development with AlgoKit — project initialization, CLI commands, example search, contract building workflows, ARC standards, and error troubleshooting. This is the parent skill for language-agnostic Algorand development. Use when working with AlgoKit CLI, searching for examples, understanding ARC standards, creating new projects, or troubleshooting errors. Strong triggers include "algokit init", "algokit project run build", "start localnet", "find an example", "search for contract", "ARC-4", "ARC-56", "logic eval error", "transaction rejected", "overspend", "create a new project", "initialize project".
---

# Algorand Development

This is the aggregated parent skill for language-agnostic Algorand development tools, workflows, and standards. Use the reference files below to find detailed guidance for each topic.

## Quick Start

```bash
# Install AlgoKit CLI
pipx install algokit

# Create a new project
algokit init -n my-project -t typescript --answer preset_name production --defaults

# Development cycle
algokit project run build    # Compile contracts
algokit project run test     # Run tests
algokit localnet start       # Start local network
algokit project deploy localnet  # Deploy
```

## Reference Guide

Navigate to the appropriate reference based on your task.

### AlgoKit CLI Commands

Build, test, deploy, and manage local networks with AlgoKit CLI.

- [use-algokit-cli.md](./references/use-algokit-cli.md) — CLI workflow and common commands
- [use-algokit-cli-reference.md](./references/use-algokit-cli-reference.md) — Full CLI command reference

### Searching Algorand Examples

Find working contract examples and code patterns from Algorand Foundation repositories.

- [search-algorand-examples.md](./references/search-algorand-examples.md) — Search workflow and priority repos
- [search-algorand-examples-reference.md](./references/search-algorand-examples-reference.md) — GitHub MCP tools reference

### Creating Projects

Initialize new Algorand projects using AlgoKit templates.

- [create-project.md](./references/create-project.md) — Project creation workflow
- [create-project-reference.md](./references/create-project-reference.md) — Templates, presets, and CLI options

### Building Smart Contracts

General workflow for building Algorand smart contracts (language-agnostic steps).

- [build-smart-contracts.md](./references/build-smart-contracts.md) — Contract building workflow
- [build-smart-contracts-reference.md](./references/build-smart-contracts-reference.md) — Repository priorities and pattern lookups

### Implementing ARC Standards

ARC-4 ABI encoding, ARC-32/ARC-56 application specifications, and related standards.

- [implement-arc-standards.md](./references/implement-arc-standards.md) — ARC overview and key standards
- [implement-arc-standards-arc4.md](./references/implement-arc-standards-arc4.md) — ARC-4 ABI types, encoding, and method invocation
- [implement-arc-standards-arc32-arc56.md](./references/implement-arc-standards-arc32-arc56.md) — Application specification format and usage

### Troubleshooting Errors

Diagnose and fix common Algorand development errors.

- [troubleshoot-errors.md](./references/troubleshoot-errors.md) — Error diagnosis overview
- [troubleshoot-errors-contract.md](./references/troubleshoot-errors-contract.md) — Smart contract and logic errors
- [troubleshoot-errors-transaction.md](./references/troubleshoot-errors-transaction.md) — Transaction and account errors

## Topic Quick Reference

| Topic | Files | Description |
| ----- | ----- | ----------- |
| AlgoKit CLI | 2 | Build, test, deploy commands and localnet management |
| Search Examples | 2 | GitHub MCP tools for finding Algorand code examples |
| Create Project | 2 | algokit init templates, presets, and options |
| Build Contracts | 2 | Language-agnostic contract building workflow |
| ARC Standards | 3 | ARC-4 ABI, ARC-32/56 app specs |
| Troubleshoot | 3 | Error diagnosis for contracts and transactions |

## How to Use This Skill

1. **Start here** to understand which reference you need
2. **Read the topic `.md`** file for step-by-step guidance
3. **Consult the `-reference.md`** file for detailed API/CLI details
4. **For language-specific content**, see the `algorand-typescript` or `algorand-python` parent skills
