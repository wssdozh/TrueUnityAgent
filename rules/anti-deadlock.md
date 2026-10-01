---
name: anti-deadlock
description: Protocols for preventing agent hallucination, infinite loops, over-engineering (Ponytail ladder), and root-cause bug fixing in Unity.
---

# Root-Cause Bug Fixing & Anti-Overengineering

> Protection against infinite loops, accumulating crutches, and architectural bloat in Unity.  
> The agent must resolve the root cause of issues and write minimal, sufficient code without speculative flexibility.

---

## 1. The Ponytail Simplicity Ladder (Occam's Razor)

Before writing any line of code, mentally verify the steps from bottom to top:

```text
7. Minimal working code (only if lower steps do not fit)
6. Can this be solved in a single line?
5. Does an installed package already solve this? (UniTask, DOTween, PrimeTween)
4. Does native Unity functionality cover this? (Physics, NavMesh, URP, Input System)
3. Does the C# (.NET) standard library already do this? (Mathf, Span<T>, Collections)
2. Is this already implemented in the project? (Grep for local helpers and utilities first)
1. Does this need to exist at all? (YAGNI — if the feature is speculative, drop it)
```

### Laws of Minimal Code:
- **No unrequested abstractions**: single-implementation interfaces, single-object factories, ScriptableObject configs for fixed constants are strictly prohibited.
- **No code "for the future"**: if functionality is not required right now for the active task, do not create stub classes or scaffolding for it.
- **Deletion beats addition**: the shortest working diff always wins. The most reliable code is the code you never had to write.
- **If the explanation is longer than the code, delete the explanation**: paragraphs justifying simplifications in responses smuggle complexity into prose. The code must speak for itself.
- **Tag deliberate shortcuts (`// ponytail:`)**: if you deliberately choose a simple algorithm with an obvious ceiling, leave a comment detailing upgrade conditions:
  ```csharp
  // ponytail: linear search O(N), upgrade to Spatial HashGrid when N > 300
  ```
- **Lazy in solution, thorough in understanding**: the simplicity ladder reduces code size, not reading depth. Trace the entire data path from start to finish before touching a method. Skipping problem analysis is dangerous laziness that breeds incorrect fixes.

---

## 2. Fix the Root Cause, Not the Symptoms (No Crutches Policy)

A bug report or console error in Unity always reports a **symptom**, not the cause. The agent must locate the origin of the problem rather than piling on crutches.

### Prohibited Crutches:
1. **Blind `if (x != null)` scattered across callers**:
   * *Crutch*: an object was destroyed or not yet instantiated, and the agent sprinkles null checks across all calling methods.
   * *Root Cause*: broken lifecycle order or event unsubscription leak. Fix the unsubscription point or the spawn factory.
2. **Wrapping in empty `try { ... } catch { }`**:
   * *Crutch*: silencing `NullReferenceException` or `IndexOutOfRangeException` to sweep errors under the rug.
   * *Root Cause*: invalid data state or empty collection. Fix the invariant in the data model.
3. **Frame-delay hacks (`WaitForEndOfFrame` / `Delay(100)`)**:
   * *Crutch*: waiting 1 frame hoping an external component finishes `Start()`.
   * *Root Cause*: non-deterministic initialization order. Fix via deterministic bootstrap or explicit `Initialize()` methods.
4. **Crutch flags**:
   * *Crutch*: introducing flags like `bool _isPatchApplied`, `bool _preventDoubleCall`, `bool _workaroundDone`.
   * *Root Cause*: fuzzy invocation logic. Make the method idempotent or separate responsibilities.

### Bug-Fixing Protocol:
1. **Trace the entire call stack** back to the point where data first became invalid.
2. **Locate all consumers via `grep`**: inspect every caller of the method or field.
3. **Fix the problem at the single shared source**: one check or contract fix at data origination fixes all consumers simultaneously and keeps the project clean.

---

## 3. The 3-Attempts Rule (Anti-Loop Rule)

When encountering a C# compilation error or Unity bug:

1. **Attempt 1**: Read the complete error log and line number carefully. Resolve the root cause.
2. **Attempt 2**: If the error persists, verify `asmdef` dependencies, `using` directives, and package versions in `manifest.json`.
3. **Attempt 3**: If the error remains, **stop**. Blind 4th and 5th attempts are prohibited.
   * The agent must halt, report exact console logs (`unity command console --level error`), and propose alternative solutions via `ask_user_question`.

---

## 4. Protecting Existing Code

- Do not delete or rewrite working project code unless explicitly required by the task.
- Do not refactor adjacent modules opportunistically — this introduces regressions and clutters git history.
- Do not modify `ProjectSettings/*.asset` without clear necessity and prior confirmation.
