# GitHub Tools Reference

Quick reference for the GitHub MCP tools for searching Algorand code examples.

## Tools

| Tool | Purpose |
|------|---------|
| `github_get_file_contents` | Read files or list directories |
| `github_search_code` | Search for code patterns |
| `github_search_repositories` | Find repositories |

## github_get_file_contents

Retrieve file contents or list directory entries from a GitHub repository.

**Parameters:**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `owner` | Yes | Repository owner (e.g., `algorandfoundation`) |
| `repo` | Yes | Repository name (e.g., `puya-ts`) |
| `path` | No | Path to file or directory (default: root) |
| `ref` | No | Git ref (branch, tag, or commit SHA) |

**Examples:**

```
# Get a specific file
github_get_file_contents owner:algorandfoundation repo:puya-ts path:examples/voting/contract.algo.ts

# List directory contents
github_get_file_contents owner:algorandfoundation repo:puya-ts path:examples

# List repo root
github_get_file_contents owner:algorandfoundation repo:devportal-code-examples

# Get file from specific branch
github_get_file_contents owner:algorandfoundation repo:puya-ts path:README.md ref:main
```

## github_search_code

Search for code patterns across GitHub repositories.

**Parameters:**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `query` | Yes | Search query (GitHub code search syntax) |
| `sort` | No | Sort field (`indexed` only) |
| `order` | No | Sort order (`asc` or `desc`) |
| `page` | No | Page number (default: 1) |
| `perPage` | No | Results per page (max 100, default: 30) |

**Query Syntax:**

| Qualifier | Example | Description |
|-----------|---------|-------------|
| `org:` | `org:algorandfoundation` | Search within organization |
| `repo:` | `repo:algorandfoundation/puya-ts` | Search specific repo |
| `language:` | `language:typescript` | Filter by language |
| `path:` | `path:examples/` | Filter by file path |
| `extension:` | `extension:ts` | Filter by file extension |

**Examples:**

```
# Search for BoxMap usage in TypeScript
github_search_code query:"BoxMap org:algorandfoundation language:typescript"

# Search for inner transactions
github_search_code query:"itxn org:algorandfoundation language:typescript"

# Search in specific repo
github_search_code query:"GlobalState repo:algorandfoundation/puya-ts"

# Search for ARC-4 implementations
github_search_code query:"arc4 abimethod org:algorandfoundation"
```

## github_search_repositories

Find repositories by name, description, topics, or other criteria.

**Parameters:**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `query` | Yes | Search query (GitHub repo search syntax) |
| `sort` | No | Sort by: `stars`, `forks`, `help-wanted-issues`, `updated` |
| `order` | No | Sort order (`asc` or `desc`) |
| `page` | No | Page number (default: 1) |
| `perPage` | No | Results per page (max 100, default: 30) |

**Query Syntax:**

| Qualifier | Example | Description |
|-----------|---------|-------------|
| `topic:` | `topic:algorand` | Filter by topic |
| `language:` | `language:typescript` | Filter by primary language |
| `org:` | `org:algorandfoundation` | Filter by organization |
| `stars:` | `stars:>100` | Filter by star count |

**Examples:**

```
# Find Algorand repos by topic
github_search_repositories query:"topic:algorand language:typescript"

# Find NFT-related Algorand projects
github_search_repositories query:"algorand nft" sort:stars order:desc

# Find repos in algorandfoundation
github_search_repositories query:"org:algorandfoundation smart-contract"

# Find popular Algorand repos
github_search_repositories query:"topic:algorand stars:>50" sort:stars
```

## Priority Repositories

| Repository | Path | Content |
|------------|------|---------|
| `devportal-code-examples` | `projects/typescript-examples/contracts/` | Beginner TypeScript |
| `devportal-code-examples` | `projects/python-examples/contracts/` | Beginner Python |
| `puya-ts` | `examples/` | Advanced TypeScript (voting, amm, auction) |
| `puya` | `examples/` | Advanced Python |
| `algokit-typescript-template` | `/` | Project template |
| `algokit-utils-ts` | `src/` | Utility library |

## Common Patterns Location

| Pattern | Repository | Path |
|---------|------------|------|
| Box storage | devportal-code-examples | `contracts/BoxStorage/` |
| BoxMap | puya-ts | `examples/voting/`, `examples/amm/` |
| Inner transactions | devportal-code-examples | `contracts/` |
| ARC-4 methods | puya-ts | `examples/hello_world_arc4/` |
| State management | devportal-code-examples | `contracts/` |
