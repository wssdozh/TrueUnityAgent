---
paths: [".git/**", "**/*"]
---

# Git Workflow Standards in Unity

> Branching standards, commit conventions, and metadata integrity in Unity repositories.  
> Eliminates data loss, merge conflicts, and GUID desynchronization.

---

## 1. Branching Strategy

- **`main`** — stable project branch. Code must compile cleanly and pass tests.
- **`feature/<name>`** — active feature or mechanic implementation (`feature/player-dash`).
- **`fix/<name>`** — bug fix targeting an exact issue (`fix/navmesh-obstacle-carve`).
- **`chore/<name>`** — package updates, tooling, project settings (`chore/update-packages`).
- **`backup/<name>`** — safety snapshots prior to major engine upgrades or LFS reorganization.

---

## 2. Unity-Specific Git Invariants

1. **Asset and `.meta` pairing**:
   * Every file and directory inside `Assets/` has an associated `.meta` file carrying a unique GUID.
   * Committing `.cs`, `.prefab`, or `.asset` files without their matching `.meta` files (or vice versa) is strictly prohibited.
   * Moving or deleting files must always include moving or deleting their corresponding `.meta` files.
2. **Exclusion of transient directories**:
   * `.gitignore` must ignore: `Library/`, `Temp/`, `Logs/`, `UserSettings/`, `MemoryCaptures/`, `Recordings/`, `Build/`, `.vs/`, `.idea/`.
3. **Git LFS for binary assets**:
   * Textures (`.png`, `.tga`, `.psd`), 3D models (`.fbx`, `.obj`), audio (`.wav`, `.mp3`), and video (`.mp4`) are tracked via Git LFS (`git lfs track "*.fbx"`).
4. **Prohibition of `push --force` to `main`**.

---

## 3. Commit Message Standard (Conventional Commits)

All commit messages are written in English, concise, and in the imperative mood:

`type(scope): imperative description`

### Types:
- **`feat`**: new mechanic, component, or system (`feat(combat): implement toothpick thrust spherecast`)
- **`fix`**: bug fix or compilation error fix (`fix(camera): correct trauma shake decay formula`)
- **`refactor`**: structural change without behavioral alterations (`refactor(enemy): decouple steering from brain`)
- **`perf`**: memory, pooling, or runtime performance optimization (`perf(pool): preallocate shatter shard rigidbodies`)
- **`chore`**: config updates, `manifest.json` packages, metadata, or agent rules (`chore(agents): add git workflow rule`)
- **`docs`**: README, GDD, or architecture documentation updates (`docs(gdd): add arena dimension specs`)

---

## 4. Pre-Merge Checklist

Prior to merging a feature branch or pushing to `main`:
1. `unity recompile --project-path .` — compilation succeeds with zero errors.
2. `git status` — no orphaned or untracked `.meta` files.
3. `unity command console --level error` — zero critical errors or exceptions in editor console.
