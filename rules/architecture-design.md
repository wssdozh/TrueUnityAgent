---
paths: ["**/*.cs"]
---

# Architecture & State Ownership

> Principles of responsibility distribution, state ownership, and subsystem decoupling in Unity.

---

## 1. Separation of Factory and Spawner

These are two distinct responsibilities that must never be mixed in a single class:

- **Factory (`Factory`)**:
  - Responsible for object instantiation and assembly.
  - Knows the prefab, instantiates it, injects dependencies (`Construct` / `Initialize`), and returns the ready instance.
  - Unaware of scene spawn coordinates, current enemy counts, or wave intervals.
- **Spawner (`Spawner`)**:
  - Responsible for game world pacing and placement.
  - Tracks spawn point transforms, wave timers, and population limits.
  - Calls the factory to create instances:
  ```csharp
  Enemy enemy = _enemyFactory.Create(spawnPoint.position, spawnPoint.rotation);
  ```

---

## 2. Single State Owner

Every piece of mutable data has exactly one owning class:

- **Wallet (`Wallet`)** — sole owner of currency. External code never modifies balances directly; it invokes methods: `wallet.TrySpend(cost)`.
- **Health (`Health`)** — sole owner of durability points.
- **Inventory (`Inventory`)** — sole owner of item collections.

**Circular dependencies and logic smear are prohibited**:
If entity A requests an item from entity B, limit validation and deduction execute inside entity B, never on the caller's side.

---

## 3. Domain Model vs Anemic Structures

Do not reduce classes to passive data bags with dozens of getters/setters surrounded by external controllers performing all operations:

- **Incorrect (anemic class)**:
  ```csharp
  // External controller inspects everything and mutates external fields:
  if (cart.Items.Count < cart.MaxCapacity && warehouse.StockCount >= requestedAmount)
  {
      cart.Items.Add(item);
      warehouse.StockCount -= requestedAmount;
  }
  ```
- **Correct (rich domain model with behavior)**:
  ```csharp
  // Validation and invariants are encapsulated within domain entities:
  if (warehouse.TryTake(productId, count, out Product product))
  {
      if (cart.TryAdd(product) == false)
      {
          warehouse.Return(product);
      }
  }
  ```

---

## 4. Interface Segregation Principle (ISP)

Do not pass monolithic system interfaces to objects that require a single capability:

- A tower needs a narrow `IAmmoProvider`, not the entire `PlayerInventory`.
- A shop needs `IProductCatalog` for prices and `IProductDispenser` for dispensing, not the entire `Warehouse`.
- This isolates modules and prevents accidental corruption of unrelated state.

---

## 5. Composition Root & Entry Point

1. **No spontaneous execution**:
   - Ad-hoc wiring across objects via `Start()` introduces non-deterministic frame bugs (`Script Execution Order`).
2. **Explicit assembly point**:
   - Every scene or game mode defines an entry point (`Bootstrap` / `EntryPoint`).
   - The entry point creates services, wires the dependency graph, and initiates the game loop in deterministic order.

---

## 6. Prohibition of Hidden Singletons and Statics

1. **Do not use static business logic**:
   - `GameManager.Instance.Player.Wallet.AddMoney(...)` creates hidden global dependencies that cannot be tested or mocked.
   - Pass dependencies explicitly: via constructors in pure C#, via `Initialize(...)` methods, or through a DI container.
2. **Exception**:
   - Pure stateless mathematical utilities (`Mathf`, `Vector3`).

---

## 7. Finite State Machines (FSM) over Flag Chains

When an entity has more than two mutually exclusive states:
- Do not accumulate boolean flags: `bool _isAttacking`, `bool _isStunned`, `bool _isDashing`, `bool _isDead`.
- Encapsulate states in an explicit Finite State Machine (FSM / State Pattern). Exactly one state is active at any time (`IdleState`, `AttackState`, `StunnedState`), and transitions are validated centrally.
