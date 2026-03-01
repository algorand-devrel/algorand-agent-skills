# AlgoKit Project Initialization

Create new Algorand projects using AlgoKit's official templates.

## Overview / Core Workflow

1. Confirm project details with user (name, template, customizations)
2. Run `algokit init` with appropriate flags
3. Handle any initialization errors
4. Provide next steps for building/testing

## How to Proceed

1. **Confirm project details with user:**
   - Project name (directory name)
   - Template choice (TypeScript or Python)
   - Any customizations (`--no-git`, `--no-bootstrap`, author name)
   - Preset selection (Production or Starter)

2. **Run initialization command:**

   **TypeScript (Production Preset):**

   ```bash
   algokit init -n <project-name> -t typescript --answer preset_name production --answer author_name "<name>" --defaults
   ```

   **TypeScript (Starter Preset):**

   ```bash
   algokit init -n <project-name> -t typescript --answer author_name "<name>" --defaults
   ```

   **Python (Production Preset):**

   ```bash
   algokit init -n <project-name> -t python --answer preset_name production --answer author_name "<name>" --defaults
   ```

   **Python (Starter Preset):**

   ```bash
   algokit init -n <project-name> -t python --answer author_name "<name>" --defaults
   ```

   **With custom options (no git, no bootstrap):**

   ```bash
   algokit init -n <project-name> -t <template> --no-git --no-bootstrap --defaults
   ```

3. **Handle errors:**
   - **Existing directory** -- Check and warn if the project directory already exists before running init
   - **AlgoKit not installed** -- Verify AlgoKit is installed with `algokit --version`
   - **Invalid template** -- Valid templates: `typescript`, `python`, `tealscript`, `react`, `fullstack`, `base`
   - **Permissions** -- Ensure target directory is writable

4. **Provide next steps:**
   - `cd <project-name>`
   - `algokit project run build` -- Compile contracts
   - `algokit project run test` -- Run test suite
   - `algokit localnet start` -- Start local network (if deploying)
   - `algokit project run deploy` -- Deploy contracts to local network

## Important Rules / Guidelines

- **Always confirm with user before executing** -- Never run `algokit init` without explicit confirmation
- **Use production preset** -- For any serious project because it includes testing framework and deployment scripts
- **Include author name** -- Pass `--answer author_name "<name>"` for attribution
- **Use `--defaults`** -- Accepts all other default values for non-interactive mode

## Common Variations / Edge Cases

| Scenario | Approach |
|----------|----------|
| Existing directory | Check and warn if directory already exists |
| No Git initialization | Use `--no-git` flag |
| No dependency installation | Use `--no-bootstrap` flag |
| Custom author name | `--answer author_name "Your Name"` |
| Fullstack (frontend + contracts) | Use `-t fullstack` template |
| React frontend only | Use `-t react` template |
| Standalone (no workspace) | Use `--no-workspace` flag |
| Initialize from example | Use `algokit init example` subcommand |

## References / Further Reading

- [CLI Reference](./create-project-reference.md)
- [AlgoKit CLI Init Documentation](https://dev.algorand.co/algokit/cli/init/)
- [AlgoKit CLI Init Reference](https://dev.algorand.co/reference/algokit-cli#init)
