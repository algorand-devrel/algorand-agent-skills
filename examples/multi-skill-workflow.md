# Multi-Skill Workflow Example

This example demonstrates how multiple Algorand Agent Skills work together in a realistic development flow: creating a voting smart contract from scratch.

## Scenario

You want to build a simple voting contract where:

- An admin can create proposals
- Users can vote on proposals
- Anyone can read vote counts

## Workflow

### 1. Initialize Project

**You say:** "Create a new AlgoKit project called voting-app"

**Skills activated:** `creating-projects`

**What happens:**

1. Agent confirms project details
2. Runs: `algokit init -n voting-app -t typescript --answer preset "Production" --defaults`
3. Provides next steps for building

### 2. Research Patterns

**You say:** "Search the Algorand docs for voting contract patterns"

**Skills activated:** None (MCP tool used directly)

**What happens:**

1. Agent uses `kappa_search_algorand_knowledge_sources` to search docs
2. Returns relevant documentation about:
   - Box storage for vote counts
   - GlobalState for proposals
   - Access control patterns

### 3. Get Example Code

**You say:** "Show me an example voting contract from the official repos"

**Skills activated:** `searching-algorand-examples`

**What happens:**

1. Agent uses `github_get_file_contents` to retrieve examples from:
   - `algorandfoundation/devportal-code-examples`
   - `algorandfoundation/puya-ts`
2. Returns relevant voting or DAO contract examples

### 4. Build the Contract

**You say:** "Create a voting contract based on those patterns"

**Skills activated:** `building-smart-contracts`, `algorand-typescript-rules`

**What happens:**

1. Agent follows the `building-smart-contracts` workflow:
   - Uses docs and examples gathered earlier
   - Generates Algorand TypeScript contract code
   - Includes proper AVM types (`uint64`, not `number`)
   - Uses `clone()` for complex state operations
2. Creates `contracts/VotingContract.algo.ts`:

```typescript
import {
  Account,
  BoxMap,
  Contract,
  GlobalState,
  Txn,
  Uint64,
  assert,
  clone,
  uint64,
} from "@algorandfoundation/algorand-typescript";

export class VotingContract extends Contract {
  admin = GlobalState<Account>({ key: "admin" });
  proposals = BoxMap<string, uint64>({ keyPrefix: "p" });

  createApplication(): void {
    this.admin.value = Txn.sender;
  }

  createProposal(name: string): void {
    assert(Txn.sender === this.admin.value, "Only admin can create proposals");
    this.proposals(name).value = Uint64(0);
  }

  vote(proposalName: string): void {
    const current = clone(this.proposals(proposalName).value);
    this.proposals(proposalName).value = current + Uint64(1);
  }

  getVotes(proposalName: string): uint64 {
    return clone(this.proposals(proposalName).value);
  }
}
```

### 5. Write Tests

**You say:** "Add tests for the voting contract"

**Skills activated:** `testing-smart-contracts`

**What happens:**

1. Agent creates test file using generated client
2. Includes tests for:
   - Creating proposals (admin only)
   - Voting on proposals
   - Reading vote counts
   - Access control (non-admin rejection)

### 6. Build and Test

**You say:** "Build and run the tests"

**Skills activated:** `algokit-commands`

**What happens:**

1. Agent runs: `algokit project run build`
2. Agent runs: `algokit project run test`
3. Reports results and fixes any issues

### 7. Deploy to Localnet

**You say:** "Deploy the contract to localnet"

**Skills activated:** `calling-smart-contracts`, `managing-networks`

**What happens:**

1. Agent verifies localnet is running: `algokit localnet start`
2. Runs: `algokit project deploy localnet`
3. Notes the deployed App ID

### 8. Interact with Contract

**You say:** "Create a proposal called 'Upgrade v2' and cast a vote"

**Skills activated:** `calling-smart-contracts`

**What happens:**

1. Agent uses MCP tools to interact:
   ```
   call_contract(appId: 1234, methodSignature: "createProposal(string)void", args: ["Upgrade v2"])
   call_contract(appId: 1234, methodSignature: "vote(string)void", args: ["Upgrade v2"])
   ```
2. Reads the vote count:
   ```
   call_contract(appId: 1234, methodSignature: "getVotes(string)uint64", args: ["Upgrade v2"])
   ```

## Skills Used in This Workflow

| Step          | Skills                                                  | MCP Tools                                 |
| ------------- | ------------------------------------------------------- | ----------------------------------------- |
| 1. Initialize | `creating-projects`                                     | -                                         |
| 2. Research   | -                                                       | `kappa_search_algorand_knowledge_sources` |
| 3. Examples   | `searching-algorand-examples`                           | `github_get_file_contents`                |
| 4. Build      | `building-smart-contracts`, `algorand-typescript-rules` | -                                         |
| 5. Test       | `testing-smart-contracts`                               | -                                         |
| 6. Build/Test | `algokit-commands`                                      | -                                         |
| 7. Deploy     | `calling-smart-contracts`, `managing-networks`          | -                                         |
| 8. Interact   | `calling-smart-contracts`                               | `call_contract`                           |

## Key Takeaways

1. **Skills chain naturally** - Each skill builds on the previous step
2. **MCP tools complement skills** - Docs search and contract calls enhance skill guidance
3. **The agent follows patterns** - Skills ensure consistent, correct Algorand code
4. **Testing is integrated** - The workflow includes testing as a core step
5. **CLI for deploy, MCP for interact** - Use the right tool for each task
