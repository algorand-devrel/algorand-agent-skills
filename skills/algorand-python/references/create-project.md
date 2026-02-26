# AlgoKit Project Initialization (Python)

Create new Algorand Python projects using AlgoKit's official templates.

## Overview / Core Workflow

1. Confirm project details with user (name, preset, customizations)
2. Run `algokit init` with the Python template
3. Handle any initialization errors
4. Provide next steps for building/testing

## How to Proceed

1. **Confirm project details with user:**
   - Project name (directory name)
   - Preset choice (Production or Starter)
   - Any customizations (`--no-git`, `--no-bootstrap`, author name)
   - Deployment language preference (Python or TypeScript)

2. **Run initialization command:**

   **Python (Production Preset):**

   ```bash
   algokit init -n <project-name> -t python --answer preset_name production --answer author_name "<name>" --defaults
   ```

   **Python (Starter Preset):**

   ```bash
   algokit init -n <project-name> -t python --answer author_name "<name>" --defaults
   ```

   **Python with TypeScript deployment scripts:**

   ```bash
   algokit init -n <project-name> -t python --answer deployment_language "typescript" --defaults
   ```

3. **Handle errors:**
   - Check if project directory already exists
   - Verify AlgoKit is installed: `algokit --version`
   - Ensure target directory is writable

4. **Provide next steps:**
   - `cd <project-name>`
   - `algokit project run build` -- Compile contracts
   - `algokit project run test` -- Run test suite
   - `algokit localnet start` -- Start local network (if deploying)
   - `algokit project run deploy` -- Deploy contracts to local network

## Python-Specific Customizations

| Customization | Command |
|---------------|---------|
| Set author name | `--answer author_name "Your Name"` |
| Production preset | `--answer preset_name production` |
| Starter preset | Omit `preset_name` (default) |
| TypeScript deployment scripts | `--answer deployment_language "typescript"` |
| Skip git init | `--no-git` |
| Skip dependency install | `--no-bootstrap` |

## Important Rules / Guidelines

- **Always confirm with user before executing** -- Never run `algokit init` without explicit confirmation
- **Use production preset** -- For any serious project because it includes testing framework and deployment scripts
- **Include author name** -- Pass `--answer author_name "<name>"` for attribution
- **Use `--defaults`** -- Accepts all other default values for non-interactive mode
- **Deployment language** -- Python projects can optionally use TypeScript for deployment scripts via `--answer deployment_language "typescript"`

## References / Further Reading

- [CLI Reference](./create-project-reference.md)
- [AlgoKit CLI Init Documentation](https://dev.algorand.co/algokit/cli/init/)
- [AlgoKit CLI Init Reference](https://dev.algorand.co/reference/algokit-cli#init)
