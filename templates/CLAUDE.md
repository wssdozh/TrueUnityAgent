# CLAUDE.md — Universal Unity Project Agent Guide

> Guide for autonomous AI agents working on Unity projects.  
> Primary source of truth: **`AGENTS.md`** and the **`.agents/rules/`** directory.

---

## Project Context

- **Engine**: Unity 6+ (URP / HDRP)
- **Language**: C# (explicit types, `_camelCase` private fields, `UPPER_SNAKE_CASE` constants)
- **Editor Control**: Official Unity CLI (`unity`)
- **Async**: `UniTask` (`UniTask<T>`, `UniTaskVoid`) with mandatory `Async` suffix
- **Input**: New Input System (`UnityEngine.InputSystem`)

---

## Repository Structure (Zero Junk Policy)

All custom game assets and code live strictly inside `Assets/_Project/`:
- `Assets/_Project/Develop/Runtime/` — Runtime C# scripts organized by feature
- `Assets/_Project/Develop/Editor/` — Editor-only tools and property drawers
- `Assets/_Project/Scenes/` — Scene files (`_Core/`, `Gameplay/`, `Sandboxes/`)
- `Assets/_Project/Prefabs/` — Entity, environment, and UI prefabs
- `Assets/_Project/Art/` — Materials (`M_*`), shaders, models, textures

---

## Rule Routing (`.agents/rules/`)

Consult specialized rule modules before acting on tasks:
1. **Workflow & Feature Gate** ➔ read `.agents/rules/readiness-and-delivery.md` (Feature Gate $\ge 90\%$, autonomy, interview protocol, DoD)
2. **Errors & Over-engineering** ➔ read `.agents/rules/anti-deadlock.md` (root causes over crutches, Ponytail ladder)
3. **Git & Branches** ➔ read `.agents/rules/git-workflow.md` (`.meta` pairing, English Conventional Commits)
4. **C# Code Standards** ➔ read `.agents/rules/code-style.md`
5. **Architecture & Decoupling** ➔ read `.agents/rules/architecture-design.md` (Factory vs Spawner, Single State Owner, ISP)
6. **Unity Engine & Memory** ➔ read `.agents/rules/unity-best-practices.md` (SO immutability, pool reset contract)
7. **User Interface (UI)** ➔ read `.agents/rules/ui-toolkit-pipeline.md` (HTML browser prototype, 95% layout fidelity)
8. **Scene & Build Management** ➔ read `.agents/rules/unity-cli.md` (no raw text editing of `.unity`/`.prefab` YAML!)
9. **File Hierarchy & Assets** ➔ read `.agents/rules/project-structure.md`

---

## Agent Workflow Loop

1. **Before Coding**: gather requirements and construct a Feature Readiness card ($\ge 90\%$ confidence).
2. **Scene Manipulation**: inspect `unity status`. If editor is running, drive it via `unity command`.
3. **After C# Modifications**:
   - Run `unity recompile --project-path .`
   - Inspect console: `unity command console --level error --tail 20`
4. **Commits**: atomic, descriptive, English Conventional Commits (`feat:`, `fix:`, `refactor:`, `chore:`).
