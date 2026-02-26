---
name: algorand-python
description: Comprehensive guide for Algorand Python (PuyaPy) smart contract development — contract building with decorators, storage, transactions, types, AlgoKit Utils, ARC standards, and troubleshooting. This is the parent skill for all Python-specific Algorand content. Use when writing Python contract code, working with algopy decorators, understanding Algorand Python storage patterns, using AlgoKit Utils in Python, or troubleshooting Python-specific errors. Strong triggers include "Algorand Python", "PuyaPy", "algopy", "ARC4Contract", "@arc4.abimethod", "GlobalState Python", "BoxMap Python", "algokit_utils Python", "pip install algokit-utils", "Python contract", "Python smart contract".
---

# Algorand Python

This is the aggregated parent skill for all Python-specific Algorand development. Use the reference files below to find detailed guidance for each topic.

## Quick Start

```bash
# Create Python project
algokit init -n my-project -t python --answer preset_name production --defaults

# Install AlgoKit Utils
pip install algokit-utils

# Development cycle
algokit project run build    # Compile Python contracts
algokit project run test     # Run tests
```

### Key Python Pattern

```python
from algopy import ARC4Contract, arc4

class MyContract(ARC4Contract):
    @arc4.abimethod
    def hello(self, name: arc4.String) -> arc4.String:
        return arc4.String("Hello, " + name.native)
```

## Reference Guide

Navigate to the appropriate reference based on your task. Each topic has one or more files.

### Creating Python Projects

Initialize Python AlgoKit projects with proper templates and presets.

- [create-project.md](./references/create-project.md) — Python project creation
- [create-project-reference.md](./references/create-project-reference.md) — Python presets and templates

### Building Smart Contracts (Python)

Python-specific contract building with PuyaPy, including deep-dive references for decorators, storage, transactions, and types.

- [build-smart-contracts.md](./references/build-smart-contracts.md) — Python contract building guide
- [build-smart-contracts-reference.md](./references/build-smart-contracts-reference.md) — Python repos and patterns
- [build-smart-contracts-decorators.md](./references/build-smart-contracts-decorators.md) — `@arc4.abimethod`, `@arc4.baremethod`, `@subroutine`
- [build-smart-contracts-storage.md](./references/build-smart-contracts-storage.md) — GlobalState, LocalState, Box, BoxMap, BoxRef
- [build-smart-contracts-transactions.md](./references/build-smart-contracts-transactions.md) — Inner transactions, group transactions, fee pooling
- [build-smart-contracts-types.md](./references/build-smart-contracts-types.md) — AVM types, ARC-4 types, reference types

### AlgoKit Utils (Python)

Interact with Algorand from Python applications.

- [use-algokit-utils.md](./references/use-algokit-utils.md) — Python AlgoKit Utils overview
- [use-algokit-utils-reference.md](./references/use-algokit-utils-reference.md) — AlgorandClient Python API reference

### Implementing ARC Standards (Python)

Python implementations of ARC-4, ARC-32, and ARC-56.

- [implement-arc-standards.md](./references/implement-arc-standards.md) — Python ARC overview
- [implement-arc-standards-arc4.md](./references/implement-arc-standards-arc4.md) — Python ARC-4 implementations
- [implement-arc-standards-arc32-arc56.md](./references/implement-arc-standards-arc32-arc56.md) — Python typed client usage

### Troubleshooting Errors (Python)

Python-specific error diagnosis and fixes.

- [troubleshoot-errors.md](./references/troubleshoot-errors.md) — Python error overview
- [troubleshoot-errors-contract.md](./references/troubleshoot-errors-contract.md) — Contract errors with Python fixes
- [troubleshoot-errors-transaction.md](./references/troubleshoot-errors-transaction.md) — Transaction errors with Python fixes

## Topic Quick Reference

| Topic | Files | Description |
| ----- | ----- | ----------- |
| Create Project | 2 | Python template initialization |
| Build Contracts | 6 | PuyaPy contracts, decorators, storage, transactions, types |
| AlgoKit Utils | 2 | AlgorandClient Python API |
| ARC Standards | 3 | Python ARC implementations |
| Troubleshoot | 3 | Python error fixes |

## How to Use This Skill

1. **Start here** to understand which reference you need
2. **Read the topic `.md`** file for step-by-step guidance
3. **Consult detail files** for specific subtopics (decorators, storage, types, etc.)
4. **For language-agnostic content** (CLI, ARC specs, general workflows), see the `algorand-development` parent skill
