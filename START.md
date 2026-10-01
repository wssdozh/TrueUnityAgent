# START.md — Project Self-Adaptation Protocol for Autonomous Agents

> This file is read by autonomous AI agents (DeepSeek Harness, Claude Code, Cursor) when bootstrapping `true-unity-agent` rules in a new or existing Unity project.  
> **Agent Objective**: Autonomously inspect the project, identify its active technology stack and directory layout, and adapt project context files (`AGENTS.md` / `CLAUDE.md`).

---

## Agent Instructions: Sequential Execution

Follow these steps strictly in sequence:

### Step 1. Project Reconnaissance
Do not ask the user for information already present in codebase files. Inspect the repository autonomously:

1. **Engine Version**:
   - Read `ProjectSettings/ProjectVersion.txt` (e.g., `m_EditorVersion: 6000.3.25f1`).
2. **Packages & Dependencies**:
   - Read `Packages/manifest.json`.
   - Identify:
     * *Render Pipeline*: URP (`com.unity.render-pipelines.universal`), HDRP, or Built-in.
     * *Input*: New Input System (`com.unity.inputsystem`) or Legacy Input.
     * *Async*: UniTask (`com.cysharp.unitask`) or standard `Task`.
     * *Architecture & DI*: Morpeh ECS, Entitas, Zenject, VContainer, or pure MonoBehaviour.
     * *UI*: UI Toolkit (`com.unity.ui`), TextMeshPro, or uGUI.
     * *Navigation & Physics*: `com.unity.ai.navigation`, Unity Physics.
3. **Directory Structure & `asmdef` Assemblies**:
   - Inspect `Assets/`: check if `Assets/_Project/` or a custom convention is used.
   - Locate all `.asmdef` files via `glob` (identify `Runtime` and `Editor` assembly boundaries).
4. **Scenes & Entry Points**:
   - Discover scene files (`glob pattern: "**/*.unity"`).
   - Identify bootstrap scene (`Boot`, `Init`, `GameEntryPoint`, `SampleScene`).
5. **Git Status**:
   - Run `git status` — ensure working tree is clean and uncommitted human changes are protected.

---

## Step 2. Record Project Context (`AGENTS.md` & `CLAUDE.md`)

Based on discovered facts, open **`AGENTS.md`** (and **`CLAUDE.md`**, if present) and populate:

1. **Project Header**:
   - Game/Project name (from `README.md` or root directory name).
   - Confirmed tech stack (Unity version, Render Pipeline, Async, Input, DI/ECS).
2. **Actual Directory Structure**:
   - Replace template folder tree with actual layout of this project.
3. **Stack-Specific Rules**:
   - If specialized frameworks are detected (e.g., VContainer, Morpeh, FishNet), append appropriate entries to the `.agents/rules/` routing table.

---

## Step 3. Compilation & Editor Verification

1. Run `unity status --format json` (verify if editor instance is active).
2. Run `unity recompile --project-path .` (confirm clean compilation).
3. Inspect editor console for critical errors: `unity command console --level error --tail 20`.

---

## Step 4. Concise Report to Developer

Upon completing setup, output a brief report:
- **Detected Stack**: Unity version, Render Pipeline, Input, Architecture.
- **Updated Files**: Context files adapted to this project.
- **Compilation Status**: Clean build confirmation.
- **Next Step**: Readiness to execute backlog tasks.
