---
paths: ["**/*"]
---

# Feature Alignment, Interview Protocol & Autonomous Execution

> Rules for role ownership, resolving uncertainties (Pre-flight), autonomous execution cycles, and cross-agent handoff.

---

## 1. Role Boundaries

### Project Owner (Human):
- Game design, gameplay rules, game balance, and economy.
- Feature priorities and scope boundaries.
- Approval of foundational architectural choices.
- Subjective evaluation of game feel during playtests.

### Agent:
- Turning the approved brief into robust, verified code.
- Day-to-day engineering decisions within the selected architecture.
- Preserving project directory structure and user-authored code.
- Transparent reporting on test results, compilation checks, and lingering risks.

**No unauthorized design liberties**: The agent is strictly prohibited from silently inventing gameplay rules, balance values, item names, UI copy, or altering control schemes. If a detail is missing, clarify it before writing code.

---

## 2. Feature Readiness Gate

Before implementing any non-trivial mechanic, system, or refactoring, the agent must assemble context and produce a readiness card:

```text
Feature Readiness:
- goal: <what the player or system concretely receives>
- behavior and boundaries: <what changes and what remains untouched>
- integrations/data: <affected scripts, configs, and contracts>
- acceptance: <observable criteria for successful verification>
- delegated assumptions: <assumptions delegated to agent discretion>
- confidence: <0-100%>
```

### Pre-flight Verification Rules:
1. **Coding is prohibited below 90% confidence**:
   - If behavior, state flows, input bindings, or data contracts remain ambiguous, ask the human first.
2. **Discover codebase facts autonomously**:
   - Do not ask the user for information already present in the repository: inspect package versions (`manifest.json`), existing components, or scenes using `grep` and file reading tools.

---

## 3. Interview Protocol (Clarifying Ambiguities)

When clarifying requirements or choosing an architectural direction:

1. **Baseline context checklist**:
   - *Target platform*: Desktop vs Mobile (draw call ceilings, VRAM budgets, multiple cameras in URP).
   - *Runtime scale*: object count processed concurrently (10 vs 5,000) and update frequency.
   - *Active package stack*: UniTask vs Coroutines, New Input System, ECS vs MonoBehaviour, networking stack.
   - *Prior attempts*: for rewrites, what was attempted previously and why did it fail.
   - *Hard constraints*: systems that must not break (public API, save file schemas, shared prefabs).
2. **One question at a time**:
   - Resolve one branch of the decision tree per step. Never dump a 5-question wall of text.
3. **Structured choices (`ask_user_question`)**:
   - Offer 2–4 concrete technical options detailing engineering trade-offs.
   - Place the recommended option first, marked with `(Recommended)`.
   - Always allow custom human input (`custom`).
4. **Adaptive branching**:
   - The subsequent question must depend on the previous selection. Never ask questions along discarded branches.
5. **No unnecessary preamble**: 1–2 lines describing the dilemma followed immediately by concrete options.

---

## 4. Autonomous Delivery

Once the Feature Readiness Gate is passed ($\ge 90\%$ confidence):

1. **Execute autonomously to full completion**:
   - Do not stop after each file asking "shall I continue?".
   - Write code ➔ run `unity recompile` ➔ fix compiler errors ➔ inspect console for runtime exceptions ➔ commit results.
2. **Halt only on genuine blockers**:
   - Unresolvable product conflict in game logic.
   - Requirement to install heavy external packages.
   - Risk of user data loss or unrecoverable scene corruption.

---

## 5. Cross-Agent Handoff

When completing a task or transferring context across sessions, format a concise handoff block:

```markdown
### Cross-Agent Handoff
- **Task / Symptom**: <what was requested or which bug was reported>
- **Root Cause**: <why the bug occurred or why this solution was selected>
- **Changes**: <affected systems, C# files, prefab components>
- **Verification**: <results of unity recompile, tests, and console inspection>
- **Remaining / Out of Scope**: <next steps or remaining backlog items>
```

---

## 6. Definition of Done (DoD)

A task is considered complete only when:
1. In-game behavior matches the approved brief.
2. Compilation succeeds with zero errors: `unity recompile --project-path .`.
3. Editor console reports zero new errors or exceptions (`unity command console --level error`).
4. All newly created files reside strictly inside `Assets/_Project/`.
5. Changes are committed via atomic English Conventional Commits.
