# AGENTS.md — Master Agent Instructions (Unity Template)

> Instructions for autonomous AI agents in Unity 6+ projects.  
> All rules are modularized across the `.agents/rules/` directory.

---

## ⚡ Task-Driven Context Loading (Strict JIT)

**Do NOT read all rules upfront.**  
Every token in your context window costs latency and reasoning depth. Read only the specific rule files directly required for the current task, no more, no less:

- **C# gameplay / code**: read `code-style.md` (+ `architecture-design.md` if creating new classes/factories/interfaces).
- **Unity Engine lifecycle, memory, pooling**: read `unity-best-practices.md`.
- **Unity Editor actions (scenes, prefabs, baking)**: read `unity-cli.md`.
- **Planning / feature alignment**: read `readiness-and-delivery.md`.
- **Bugs / crashes**: read `anti-deadlock.md` (root-cause diagnosis).
- **UI Toolkit**: read `ui-toolkit-pipeline.md`.
- **Git commits / PRs**: read `git-workflow.md`.

*Combine only the modules the active task touches. Never batch-read unused files.*

---

## Rule Routing (`.agents/rules/`)

### 1. Workflow & Safety
- **Feature Alignment & Delivery** ➔ [`.agents/rules/readiness-and-delivery.md`](./.agents/rules/readiness-and-delivery.md): role boundaries (human/agent), Feature Readiness Gate ($\ge 90\%$), interview protocol, autonomous delivery, Cross-Agent Handoff, Definition of Done.
- **Errors & Over-engineering** ➔ [`.agents/rules/anti-deadlock.md`](./.agents/rules/anti-deadlock.md): Ponytail simplicity ladder (YAGNI, stdlib, minimal entities), root-cause bug fixing over crutches, 3-attempts rule.
- **Git & Branches** ➔ [`.agents/rules/git-workflow.md`](./.agents/rules/git-workflow.md): branching strategy (`feature/*`, `fix/*`, `backup/*`), paired `.meta` file safety, English Conventional Commits.

### 2. Engineering & Architecture
- **C# Code Style** ➔ [`.agents/rules/code-style.md`](./.agents/rules/code-style.md): naming from entity to property (`playerHealth`), explicit types over `var`, pure getters, `ArgumentException` vs `InvalidOperationException`, UniTask standards.
- **Architecture & Ownership** ➔ [`.agents/rules/architecture-design.md`](./.agents/rules/architecture-design.md): Factory vs Spawner separation, Single State Owner, rich domain models over anemic data bags, narrow interfaces (ISP), Composition Root.
- **Unity Best Practices** ➔ [`.agents/rules/unity-best-practices.md`](./.agents/rules/unity-best-practices.md): runtime immutability of ScriptableObjects, prohibition of silent returns, object pool reset contract, Animator view decoupling, `TryGetComponent`, `sqrMagnitude`.

### 3. Tools & Assets
- **UI Toolkit Pipeline** ➔ [`.agents/rules/ui-toolkit-pipeline.md`](./.agents/rules/ui-toolkit-pipeline.md): two-gate pipeline (HTML/CSS browser prototype ➔ approval ➔ Unity UI Toolkit), 95% layout fidelity contract, UXML + USS + retained-mode.
- **Editor Control** ➔ [`.agents/rules/unity-cli.md`](./.agents/rules/unity-cli.md): prohibition of direct text editing of `.unity`/`.prefab` YAML while editor is running. `unity command` driving, `unity recompile` loop, live log inspection.
- **File Hierarchy** ➔ [`.agents/rules/project-structure.md`](./.agents/rules/project-structure.md): Zero Junk Policy (`Assets/_Project/`), asset naming standards, assembly boundaries via `asmdef`.

---

## Anti-Overengineering (Ponytail Principles)

1. **YAGNI**: Do not write code for speculative future needs.
2. **Use Native Solutions**: Unity native APIs and the C# standard library already contain the solution.
3. **One class with a single task** beats five layers of factories and interfaces.
4. **Code ➔ Recompile ➔ Verify**: Zero unverified code commits.
