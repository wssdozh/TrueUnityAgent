---
paths: ["**/*.cs", "**/*.unity", "**/*.prefab"]
---

# Unity Gotchas & Constraints: Memory, References & Serialization

> Engine-specific rules for components, lifecycles, and memory management in Unity.

---

## 1. Serialization & Component Dependencies

1. **Prohibition of `GameObject` serialization**:
   - `[SerializeField] private CharacterView _prefab;` instead of `[SerializeField] private GameObject _prefab;`.
   - Fields must be strictly typed to the target component or `Transform`. This guarantees invalid prefabs cannot be assigned and eliminates redundant `GetComponent` calls on spawn.
2. **Mandatory `TryGetComponent`**:
   - Never use blind `GetComponent` on external objects. `TryGetComponent` causes zero heap allocations and immediately verifies existence:
   ```csharp
   if (collider.TryGetComponent(out IDamageable target))
   {
       target.TakeDamage(_damage);
   }
   ```
3. **Prohibition of silent returns on missing dependencies**:
   - Never write `if (_rigidbody == null) return;` inside `Update()` / `FixedUpdate()` — this masks prefab setup errors.
   - Validate references in `Awake()` with explicit exceptions:
   ```csharp
   private void Awake()
   {
       if (TryGetComponent(out _rigidbody) == false)
       {
           throw new MissingComponentException($"[PhysicsMover] Rigidbody not found on {gameObject.name}");
       }
   }
   ```
4. **Lifecycle boundary: `Awake` vs `Start` / `Initialize`**:
   - C# constructors are prohibited on `MonoBehaviour` classes (instances are constructed natively by the engine).
   - In `Awake()`: strictly local self-setup (local fields, `TryGetComponent` on self). Accessing external scene components in `Awake` is prohibited because cross-object execution order is non-deterministic.
   - In `Start()` or an explicit `Initialize(...)` / `Construct(...)` method: wire external cross-component dependencies and launch systems.

---

## 2. Runtime Immutability of ScriptableObjects

1. **`ScriptableObject` is an immutable Data Definition**:
   - Fields are configured in the inspector.
   - **Modifying ScriptableObject fields at runtime is strictly prohibited**:
     - In the Unity Editor, runtime mutations persist to disk in `.asset` files and overwrite source values.
     - In standalone builds, mutations persist across scene reloads and corrupt game state.
2. **Dynamic state belongs in entity instances**:
   - Configs specify base stats (`MaxHealth`, `BaseSpeed`).
   - Active dynamic values (`CurrentHealth`, `CurrentSpeed`) live in MonoBehaviour components, C# models, or ECS components.

---

## 3. Animator Decoupling & Entity Decomposition

1. **`Animator` is purely a passive view**:
   - The `Animator` component must never contain game logic, state management, or character stats.
   - The entity controller passes parameters into the animator (`_animator.SetFloat(SpeedHash, speed)`). The animator never calls domain business logic directly.
2. **Cache Animator and Shader IDs**:
   - Passing string literals to animation and material methods is prohibited: `_animator.Play("Run")`, `_animator.SetFloat("Speed", 1f)`, `_material.SetFloat("_Cutoff", 0.5f)`. The engine hashes strings on every invocation.
   - Use integer hashes cached in `static readonly int` fields: `private static readonly int SpeedHash = Animator.StringToHash("Speed");` and `Shader.PropertyToID("_Cutoff")`. String-based coroutines `StartCoroutine("MoveRoutine")` are prohibited.
3. **Single Responsibility in movement & behavior (SRP)**:
   - Do not combine movement, rotation, pathfinding, health, and spawning in a single script.
   - `Mover` translates, `Rotator` rotates, `NavAgent` steers, `Health` tracks damage, `View` renders visual effects.

---

## 4. Memory, GC & Object Pooling Contracts

1. **Object Pool Reset Contract**:
   - On release to pool and prior to re-acquisition, the object must reset its state completely:
     * Reset physics: `rigidbody.linearVelocity = Vector3.zero; rigidbody.angularVelocity = Vector3.zero;`
     * Cancel running coroutines and active tweens.
     * Reset health, cooldown timers, and visual particle systems.
2. **Zero allocations in properties and getters**:
   - Calling `.ToArray()`, `.ToList()`, `new List<T>()` inside properties or per-frame methods is prohibited.
   - Expose `IReadOnlyList<T>` referencing an existing internal list.
3. **Cache `WaitForSeconds`**:
   - Do not instantiate `new WaitForSeconds(...)` every loop iteration. Cache the instance or use `UniTask.Delay(TimeSpan, cancellationToken: ct)`.
4. **Zero LINQ & Zero GC Alloc in hot paths (`Update` / `FixedUpdate`)**:
   - LINQ (`Where`, `Select`, `OrderBy`, `FirstOrDefault`) is prohibited inside frame updates or methods called frequently. Closures and iterators allocate garbage on the heap, triggering GC spikes. Use classic index-based `for` loops.
   - String concatenation and interpolation inside `Update` are prohibited (`_text.text = $"Score: {_score}"` updates only on score-change events).
5. **Mandatory `NonAlloc` physics queries**:
   - Allocating queries are prohibited: `Physics.OverlapSphere`, `Physics.RaycastAll`.
   - Use `Physics.OverlapSphereNonAlloc` and `Physics.RaycastNonAlloc` with preallocated buffer arrays (`Collider[]`, `RaycastHit[]`).

---

## 5. Physics & Mathematics

1. **Distances strictly via `sqrMagnitude`**:
   - `Vector3.Distance` computes a square root. Compare squared magnitudes:
   ```csharp
   float sqrDistance = (targetPos - transform.position).sqrMagnitude;
   if (sqrDistance <= _attackRange * _attackRange) { ... }
   ```
2. **Safe floating-point comparisons (`float`)**:
   - Direct equality is prohibited: `if (currentHealth == 0f)` or `if (timer == maxTime)`.
   - Use `Mathf.Approximately(a, b)` or `Mathf.Abs(a - b) < Mathf.Epsilon`.
3. **Physics strictly in `FixedUpdate`**:
   - Velocity updates, `AddForce` calls, and gameplay physics casts execute strictly in `FixedUpdate`.
4. **Coordinates in `transform.Translate` (Double-Rotation Guard)**:
   - `transform.Translate(vector)` assumes the vector is in **local** object space by default.
   - Prohibited: `transform.Translate(transform.forward * speed * Time.deltaTime)` — `transform.forward` is already a world-space vector; passing it into local `Translate` applies object rotation twice, causing erratic drifting.
   - Allowed: either locally `transform.Translate(Vector3.forward * speed * Time.deltaTime);`, or globally `transform.position += transform.forward * speed * Time.deltaTime;` (or passing `Space.World`).

---

## 6. Events & Subscriptions

1. **Standard C# `Action` over `UnityAction` / `UnityEvent` in code**:
   - `Action<T>` executes faster and avoids Unity serialization overhead.
2. **Mandatory unsubscription**:
   - Every event subscription to an external object must have a matching unsubscription in `OnDisable` or `OnDestroy`.
3. **Deferred Destruction (`Destroy` Latency)**:
   - `Destroy(gameObject)` frees objects at the end of the frame. Until frame end, `obj != null` remains true, and the object stays in scene collections.
   - When calling `Destroy`, immediately remove the entity from internal tracking lists, dictionaries, and spatial structures on the same line.
4. **Static state & Fast Play Mode**:
   - When Enter Play Mode Options has Reload Domain disabled, static events and fields retain values between Play Mode sessions, holding dead references to destroyed objects.
   - Static events are prohibited. If static state is strictly required, reset it using `[RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.SubsystemRegistration)]`.
