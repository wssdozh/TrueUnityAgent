---
paths: ["**/*.cs"]
---

# C# Code Style & Engineering Standards

> C# coding standards for Unity projects. Eliminates hidden bugs, type desync, and invalid states.

---

## 1. Type Structure & Access

1. **Namespace reflects stable assembly/feature boundary**:
   - `namespace _Project.Develop.Runtime.Gameplay.Player` (project prefix required).
2. **One type per file**: file name strictly matches the type name (`PlayerMover.cs` ➔ `public sealed class PlayerMover`).
3. **Class member order**:
   1. Events
   2. Fields & Constants (`const`, `static readonly`, `[SerializeField] private`, `private`)
   3. Constructors / Initialization
   4. Properties
   5. Unity Lifecycle (`Awake`, `OnEnable`, `Start`, `Update`, `OnDisable`, `OnDestroy`)
   6. Public methods
   7. Protected / Private methods
4. **Prohibition of `protected` fields**:
   - Fields are always `private`. Derived class access is provided via `protected` properties (`protected float Speed => _speed;`). Protected fields break base class encapsulation.
5. **Explicit access modifiers**: always declare `public`, `private`, `protected` (except on interface members).

---

## 2. Data Naming

- **Name flows from entity to property**: `playerHealth`, `objectMass`, `armorPercent`, `minNumber`, `maxNumber`.  
  *Prohibited forms*: `healthOfPlayer`, `percentOfArmor`, `fromNumber`, `toNumber`.
- **Fields & variables**:
  - `_camelCase` — private fields (`_rigidbody`, `_health`).
  - `camelCase` — local variables and parameters (`moveSpeed`, `targetPosition`).
  - `PascalCase` — public properties, methods, structs, classes.
  - `UPPER_SNAKE_CASE` — constants (`const`).
  - `static readonly` — named like regular fields (`_defaultConfig` / `DefaultConfig`), not `const`.
- **Boolean entities**: properties and methods prefixed with `Is`, `Can`, `Has` (`isAlive`, `canAttack`, `hasTarget`). Avoid `checkX` — it conceals side effects.
- **Pattern `TryX`**: methods that can fail without throwing exceptions return `bool` and output results via `out`:
  ```csharp
  public bool TryGetTarget(out Enemy target)
  ```
- **Event names indicate completed facts**: `Damaged`, `ItemAdded`. Handler: `OnDamaged`, `OnItemAdded`.
- **No tautologies or junk suffixes**: `Character.Move()`, not `Character.CharacterMove()`. Prohibited: `GameManagerController`, `ItemHelperManager`.

---

## 3. Whitespace, Indentation & Blank Lines

1. **Blank line rule**:
   - **Exactly one blank line** between methods, properties, constructors, and logical blocks (`if`, `for`, `while`, `switch`). Code must not clump into unreadable walls.
   - **Zero blank lines immediately after `{` and before `}`**:
     ```csharp
     // Incorrect:
     void TakeDamage()
     {

         _health -= 10;

     }

     // Correct:
     void TakeDamage()
     {
         _health -= 10;
     }
     ```
   - **No more than one consecutive blank line**: two or more blank lines in a row are forbidden throughout the file.
   - **Blank line between `case` blocks in `switch`**: each `case` block is separated for visual structure.
2. **Braces always on their own line (Allman Style)**:
   - Each opening `{` and closing `}` brace resides on its own line with matching indentation:
     ```csharp
     if (isGrounded)
     {
         Jump();
     }
     ```
   - Inlining code with braces on one line is prohibited: `if (x) { Do(); }`.
3. **Variable declaration**:
   - Declaring multiple variables comma-separated on a single line is prohibited (`int a = 1, b = 2;`). Each variable is declared on its own line.
4. **Spacing around operators**:
   - Spaces are required around assignment and binary operators: `a = b + c;` (not `a=b+c;`).
   - Space after control keywords: `if (condition)`, `while (isRunning)`, `switch (state)` (space between keyword and parenthesis).
5. **Line length and wrapping**:
   - Line length must not exceed 120 characters (code reads without horizontal scrolling).
   - Long method parameters and LINQ chains wrap to a new line indented by 4 spaces.

---

## 4. Language Constructs & Contracts

1. **Explicit types over `var`**:
   - `int count = 10;`, `Enemy enemy = GetComponent<Enemy>();`.
   - `var` is permitted only when the type is literally repeated on the right-hand side (`Transform t = new Transform();` or verbose generic instantiation `Dictionary<int, List<Transform>> map = new();`).
2. **Explicit check for false**:
   - `if (isAlive == false)` instead of `if (!isAlive)` — exclamation points are easily overlooked during code review diffs.
3. **Pure Getters**:
   - Property getters and inspector methods must never modify internal object state or produce side effects.
4. **Return contract: `return` vs `ref/out`**:
   - If a method calculates a single value, return it via `return`, rather than mutating an incoming `ref/out`.
5. **Exception differentiation**:
   - `ArgumentException` / `ArgumentNullException` / `ArgumentOutOfRangeException` — strictly for invalid method input arguments.
   - `InvalidOperationException` — when arguments are valid, but internal object state prohibits the operation (firing an unloaded weapon, starting an active timer).
6. **Upper bound in `Random.Next(min, max)`**:
   - Upper bound in `System.Random.Next` is exclusive. For values 1..10, pass `random.Next(1, 11)`.
7. **Input loops over recursion**:
   - Polling for valid input or states is done via loops (`while`), not recursive method re-invocation (guards against `StackOverflowException`).
8. **Prohibition of `?.` on `UnityEngine.Object` types (Fake Null)**:
   - In C#, `?.` evaluates purely at the IL level (`ldnull`) against managed references and bypasses Unity's overloaded `operator ==`. If a `GameObject` or `Component` was destroyed via `Destroy()`, the native C++ object is freed, but the C# wrapper remains alive. `target != null` evaluates to `false`, but `target?.DoSomething()` invokes methods on the dead wrapper and throws `MissingReferenceException`.
   - Prohibited: `_target?.TakeDamage();`, `_animator?.SetTrigger(hash);`.
   - Allowed: `if (_target != null) { _target.TakeDamage(); }`.
9. **Prohibition of anonymous lambdas in event subscriptions**:
   - Subscribing with anonymous lambdas to objects with a lifecycle is prohibited (`_health.Damaged += dmg => OnDamaged(dmg);` or `_button.onClick.AddListener(() => OnClick());`).
   - Anonymous delegates cannot be unsubscribed via `-=` in `OnDisable()` or `OnDestroy()`, causing memory leaks and calls on destroyed objects.
   - Allowed: subscribe strictly to named methods (`_health.Damaged += OnDamaged;`) with mandatory unsubscription in `OnDisable` or `OnDestroy`.
10. **Collection Encapsulation**:
    - Exposing public mutable collections is prohibited: `public List<Item> Items => _items;`. External code can call `Items.Clear()` or `Items.Add()` bypassing state invariants.
    - Allowed: expose read-only interfaces: `public IReadOnlyList<Item> Items => _items;` or `public IReadOnlyDictionary<int, Item> Items => _items;`. Collection mutation is allowed only through owning class methods (`TryAdd`, `TryRemove`).

---

## 5. Asynchronous Code (UniTask)

1. **UniTask exclusively in Unity**:
   - Use `UniTask`, `UniTask<T>`, `UniTaskVoid`.
   - `System.Threading.Tasks.Task` is prohibited (causes heap allocations on the engine main thread).
2. **Mandatory `Async` suffix**:
   - Any method returning `UniTask` / `UniTask<T>` / `UniTaskVoid` ends with `Async` (`ReloadGunAsync`).
3. **Prohibition of `async void`**:
   - `async void` is prohibited, except for Unity UI event handlers (`button.onClick`). In those handlers, wrap the body in `try-catch`.
   - For fire-and-forget invocations from standard methods, use `UniTaskVoid` and `.Forget()`.
4. **CancellationToken**:
   - Pass `CancellationToken cancellationToken = default` as the final parameter and forward it to nested async calls. In `MonoBehaviour`, link to `destroyCancellationToken`.
