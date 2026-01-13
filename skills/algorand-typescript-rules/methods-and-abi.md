# Methods, ABI, and Lifecycle

## Method Visibility

By default, `@abimethod` decorators are NOT necessary. Visibility determines ABI exposure:

| Visibility | Behavior |
|------------|----------|
| `public` | Automatically exposed as ABI method |
| `private` | Becomes subroutine (internal only) |

```typescript
// Public = ABI method automatically
public addTodo(text: string): uint64 { }

// Private = subroutine
private getTodoKey(account: bytes, todoId: uint64): string { }

// Decorator only when needed for config
@abimethod({ readonly: true })
public getData(): [uint64, uint64, uint64] { }
```

**When to use `@abimethod()`**: Only when you need configuration like `{ readonly: true }`, `{ allowActions: 'OptIn' }`, etc.

## Decorator Syntax

ARC4 decorators MUST be called as functions with parentheses:

```typescript
// CORRECT
@abimethod()
public update(): string { }

// INCORRECT - "Decorator function return type mismatch"
@arc4.abimethod
public update(): string { }
```

## Application Lifecycle Methods

**PREFER convention-based methods** for lifecycle events. They are automatically routed based on OnCompletion action.

| Method Name | When Called |
|-------------|-------------|
| `createApplication()` | Application creation |
| `optInToApplication()` | OnCompletion is OptIn |
| `closeOutOfApplication()` | OnCompletion is CloseOut |
| `updateApplication()` | OnCompletion is UpdateApplication |
| `deleteApplication()` | OnCompletion is DeleteApplication |

```typescript
export class TodoList extends Contract {
  todos = LocalState<TodoListData>({ key: 'todos' })

  // Convention-based: automatically routed on OptIn
  public optInToApplication(): void {
    const initialList = {
      todos: [] as Todo[],
      nextId: Uint64(1),
    }
    this.todos(Txn.sender).value = clone(initialList)
  }

  // Regular ABI methods for business logic
  public addTodo(text: string): uint64 {
    // ...
  }
}
```

## ABI Return Types

Struct objects can be returned directly. Puya converts to ABI tuples automatically:

```typescript
// CORRECT: Return struct directly
@abimethod({ readonly: true })
public getData(): MyData {
  const state = clone(this.appState.value)
  return state  // Compiler converts to ABI tuple
}

// ALSO CORRECT: Return tuple explicitly
@abimethod({ readonly: true })
public getData(): [uint64, uint64, uint64] {
  const state = clone(this.appState.value)
  return [state.field1, state.field2, state.field3]
}
```

## Type Definitions

Use plain TypeScript types for storage, not ARC4 decorators:

```typescript
// CORRECT
type MyData = { field1: uint64; field2: uint64 }

// INCORRECT
@arc4.abiTuple class MyData { }
```

## Generated Client Method Names

### Convention-based Lifecycle Methods

Convention-based methods like `optInToApplication()` are nested under their action type in generated clients:

```typescript
// Contract
public optInToApplication(): void { }

// Client call
await client.send.optIn.optInToApplication({ args: [] })
```

### Decorator-based Opt-in Methods

Methods with `@abimethod({ allowActions: 'OptIn' })` are also nested:

```typescript
// Contract
@abimethod({ allowActions: 'OptIn' })
public optIn(): void { }

// CORRECT - nested under optIn
await client.send.optIn.optIn({ args: [] })

// INCORRECT
await client.send.optIn({ args: [] })
```

**Recommendation**: Use convention-based `optInToApplication()` for better readability. Always check the generated client file to confirm exact method names.
