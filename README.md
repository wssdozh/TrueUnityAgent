<p align="center">
  <img src="assets/banner.svg" alt="true-unity-agent banner" width="760">
</p>

<h1 align="center">true-unity-agent</h1>

<p align="center">
  <em>He sees your 200-line god manager. He writes three lines. It compiles.</em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/unity-6%2B-111111?style=flat-square" alt="Unity 6+">
  <img src="https://img.shields.io/badge/agents-DSH%20%C2%B7%20Claude%20%C2%B7%20Cursor-111111?style=flat-square" alt="Works with agents">
  <img src="https://img.shields.io/badge/code-root--cause%20only-111111?style=flat-square" alt="Root cause only">
  <img src="https://img.shields.io/badge/fidelity-UI%2095%25-111111?style=flat-square" alt="UI 95% Fidelity">
  <img src="https://img.shields.io/badge/license-MIT-111111?style=flat-square" alt="MIT license">
</p>

---

You know the feeling. You ask an AI agent to add a simple shoot cooldown.  
It creates `ShotCooldownManager`, sets up a ticking `Update()`, writes an `IShotCooldownService` interface, an event bus, and a ScriptableObject config.

**true-unity-agent puts a ruthless senior engineer inside your AI agent.**

---

## Before / after

### 1. Shoot cooldown
Without rules, your agent builds a 60-line coroutine manager:
```csharp
// The typical agent slop:
StartCoroutine(CooldownRoutine());
IEnumerator CooldownRoutine() {
    yield return new WaitForSeconds(0.5f); // GC allocation every time
    _canShoot = true;
}
```

With `true-unity-agent`:
```csharp
// One float, zero allocations, deterministic:
if (Time.time < _nextFireTime) return;
_nextFireTime = Time.time + COOLDOWN;
```

### 2. Distance check
Without rules:
```csharp
// Slower sqrt calculation in Update every frame:
if (Vector3.Distance(transform.position, target.position) <= attackRange)
```

With `true-unity-agent`:
```csharp
// Zero sqrt, scalar comparison:
if ((transform.position - target.position).sqrMagnitude <= attackRange * attackRange)
```

### 3. Component lookup
Without rules:
```csharp
// Blind GetComponent + null check = garbage and runtime crashes:
var health = other.GetComponent<Health>();
if (health != null) health.TakeDamage(10);
```

With `true-unity-agent`:
```csharp
// Zero GC, safe and atomic:
if (other.TryGetComponent(out Health health)) health.TakeDamage(10);
```

---

## How it works (The Ponytail Ladder)

Before writing any code, the agent stops at the lowest rung that holds:

```text
1. Does this need to exist?   → no: skip it (YAGNI)
2. Already in this codebase?  → reuse it, don't rewrite
3. Stdlib does it?            → use it (Mathf, Span<T>, System.Collections)
4. Native Unity covers it?    → use it (Physics, NavMesh, URP, Input System)
5. Installed package does it? → use it (UniTask, DOTween, PrimeTween)
6. Can it be one line?        → one line
7. Only then:                 → minimum code that works
```

* **Bug fix = Root cause, not symptom**: Blind `if (x != null)` guards and empty `try/catch` blocks are strictly forbidden. Fix the issue once at the source of data.
* **If the explanation is longer than the code, delete the explanation**: Code speaks for itself.

---

## Rules Structure (`rules/`)

### 1. Workflow & Safety
* [`readiness-and-delivery.md`](./rules/readiness-and-delivery.md) — **Feature Gate & Delivery**: Roles (Human/Agent), Feature Readiness Gate ($\ge 90\%$), structured interview protocol (`ask_user_question`), autonomous execution without micro-pauses, Cross-Agent Handoff, Definition of Done.
* [`anti-deadlock.md`](./rules/anti-deadlock.md) — **Anti-Overengineering & Root-Cause**: Ponytail ladder, No Crutches Policy (fixing root cause), 3-attempts limit.
* [`git-workflow.md`](./rules/git-workflow.md) — **Git & Safety**: Branch strategy (`feature/*`, `fix/*`, `backup/*`), paired `.meta` file integrity, English Conventional Commits, pre-merge checklist.

### 2. Code & Architecture (Engineering)
* [`code-style.md`](./rules/code-style.md) — **C# Standards**: Entity-to-property naming (`playerHealth`), explicit types over `var`, private fields, pure getters, `ArgumentException` vs `InvalidOperationException`, UniTask only.
* [`architecture-design.md`](./rules/architecture-design.md) — **Architecture & Ownership**: Factory (creation) vs Spawner (timings/quota), Single State Owner, Rich Domain models over anemic data, narrow interfaces (ISP), Composition Root.
* [`unity-best-practices.md`](./rules/unity-best-practices.md) — **Unity Engine Invariants**: ScriptableObject immutability at runtime, no silent returns for missing dependencies, pool reset contract, Animator isolation, `TryGetComponent`, `sqrMagnitude`.

### 3. Tools & Assets
* [`ui-toolkit-pipeline.md`](./rules/ui-toolkit-pipeline.md) — **UI Toolkit 2-Gate Pipeline**: Interactive HTML/CSS mockup first in browser ➔ approval ➔ transfer to Unity. 95% layout fidelity contract, retained-mode.
* [`unity-cli.md`](./rules/unity-cli.md) — **Unity CLI Automation**: Strict ban on editing `.unity`/`.prefab` YAML files directly. Driving editor via `unity command`, compile loop via `unity recompile`, error diagnostics.
* [`project-structure.md`](./rules/project-structure.md) — **Zero Junk Policy**: Everything lives in `Assets/_Project/`. Asset naming conventions (`M_*`, `T_*`, `SH_*`, `sfx_*`), assembly boundaries via `asmdef`.

---

## Quick Install

### Method 1. One-line PowerShell script

Run the installer pointing to your Unity project root:

```powershell
.\install.ps1 -TargetPath "C:\Path\To\YourUnityProject"
```

The installer creates `.agents/rules/`, copies all modules, and installs `START.md`, `CLAUDE.md`, `AGENTS.md`, and `.cursorrules`.

### Method 2. Git Submodule

If your project is already a git repo:

```bash
git submodule add https://github.com/wssdozh/true-unity-agent.git .agents
```

### Method 3. Manual

Copy the files from `templates/` into your project root:
- `templates/.agents/` ➔ `.agents/`
- `templates/START.md` ➔ `START.md`
- `templates/AGENTS.md` ➔ `AGENTS.md`
- `templates/CLAUDE.md` ➔ `CLAUDE.md`
- `templates/.cursorrules` ➔ `.cursorrules`

---

## First agent run in a project

Once installed, just tell your AI agent:

```text
Прочитай START.md и адаптируй контекст под этот проект.
```

The agent will autonomously:
1. Inspect Unity version (`ProjectVersion.txt`) and packages (`Packages/manifest.json`).
2. Map `Assets/` folders and `.asmdef` boundaries.
3. Adapt `AGENTS.md` with the project's actual stack and directory map.
4. Verify compilation with `unity recompile`.

---

## License

[MIT](LICENSE) © [wssdozh](https://github.com/wssdozh)
