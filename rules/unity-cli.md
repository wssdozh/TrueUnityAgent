---
paths: ["**/*"]
---

# Editor Control via Unity CLI

> Interaction standards for Unity 6+ using the official CLI.  
> Prevents corruption of `.unity`, `.prefab`, and `.asset` files while ensuring clean builds.

---

## 1. Asset & Scene Safety

Direct text editing of scene (`.unity`), prefab (`.prefab`), and asset (`.asset`) YAML files while the Unity Editor is running is strictly prohibited. Modifying these files as raw text desynchronizes editor memory caches, corrupts GUIDs/FileIDs, and destroys serialized references.

All scene operations, object instantiation, component modifications, NavMesh baking, and scene saves must be performed via:
1. **Unity CLI** (`unity command ...`) when the editor instance is active.
2. C# scripts located in the `Editor/` folder (`[MenuItem]` or `InitializeOnLoad`).

---

## 2. Editor Status Pre-flight

Before executing tests, generating scenes, or compiling scripts:

```powershell
unity status --format json
```

- If the editor is active and reports `ready`: use interactive `unity command` calls.
- If the editor is not running: batch commands (`unity recompile`, `unity test`) launch a headless Unity background instance automatically.

---

## 3. Live Scene Manipulation (`unity command`)

When connected to an active editor, use CLI commands for scene assembly and object setup:

### Object Instantiation & Query:
```powershell
# Create empty GameObject
unity command create_gameobject --name "PlayerRig"

# Create primitive (Cube, Sphere, Capsule, Cylinder, Plane)
unity command create_primitive --type Cube --name "Ground_Blockout"

# Find object in scene hierarchy
unity command find_gameobject --name "PlayerRig"
```

### Component Binding & Setup:
```powershell
# Add component
unity command add_component --target "PlayerRig" --component "CharacterController"

# Trigger NavMesh bake
unity command bake_navmesh

# Save active scene
unity command save_scene
```

### Live Console Inspection:
```powershell
# Last 20 error logs from editor console
unity command console --level error --tail 20

# All warnings and errors
unity command console --level warning --tail 30
```

---

## 4. Compilation & Verification Loop

After modifying any `.cs` file, execute the verification loop:

1. **Trigger recompile**:
   ```powershell
   unity recompile --project-path .
   ```
2. **Inspect errors**:
   - If recompile returns non-zero or reports compiler diagnostic codes (`CS0246`, `CS1002`), fix root cause.
   - Inspect editor console: `unity command console --level error --tail 10`.
3. **Execute tests (when applicable)**:
   ```powershell
   unity test . --mode EditMode --report-format junit
   ```

---

## 5. Recovery on Build Failures

If the Unity Editor enters Safe Mode or compilation halts:
1. Query console: `unity command console --level error`.
2. Fix syntax and type issues in C# source files.
3. If the editor becomes unresponsive:
   - Check `Get-Process Unity`.
   - Do not force-kill immediately; run `unity recompile`.
   - Once compilation clears the lock, resume workflow.
