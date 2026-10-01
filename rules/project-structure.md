---
paths: ["Assets/**", "Packages/**"]
---

# Project Structure: Assets/_Project & Zero Junk Policy

> File, prefab, scene, and script organization standards in Unity.  
> Prevents clutter in the Assets folder and optimizes compilation times via Assembly Definitions (`asmdef`).

---

## 1. Zero Junk Policy: `Assets/_Project/` Directory

Creating random scripts, test materials, or prefabs in the root of `Assets/` is strictly prohibited.

The root of `Assets/` is divided strictly into:
- **`Assets/_Project/`** — all user code, assets, scenes, and prefabs belonging to the game. The `_` prefix pins the folder to the top of the Unity Project window.
- **External plugin and package directories** (`Assets/Plugins/`, `Assets/Settings/`, `Assets/TextMesh Pro/`).

---

## 2. Directory Hierarchy within `Assets/_Project/`

```text
Assets/_Project/
├── Develop/                     # C# source code and asmdef assemblies
│   ├── Runtime/                 # Code included in game builds
│   │   ├── Core/                # Entry point, Bootstrap, Service Locator / DI
│   │   ├── Gameplay/            # Feature-based gameplay logic
│   │   │   ├── <FeatureName>/   # Feature folder (Player, Enemies, Weapons, Building)
│   │   │   │   ├── Systems/     # Logic controllers / systems
│   │   │   │   ├── Views/       # MonoBehaviour view representations
│   │   │   │   └── Components/  # Data, models, ECS components
│   │   ├── UI/                  # Interface controllers, screens
│   │   ├── Configs/             # ScriptableObject C# classes
│   │   └── Common/              # Shared utilities, math, object pooling
│   └── Editor/                  # Editor scripts, custom tools, property drawers
├── Scenes/                      # Unity scene files (.unity)
│   ├── _Core/                   # Bootstrap / entry scenes (Boot, Init)
│   ├── Gameplay/                # Main game levels
│   └── Sandboxes/               # Developer testbeds and greyboxes
├── Prefabs/                     # Categorized prefabs
│   ├── Player/
│   ├── Enemies/
│   ├── Environment/
│   ├── VFX/
│   └── UI/
├── Art/                         # Visual source files and assets
│   ├── Materials/               # Materials (.mat)
│   ├── Shaders/                 # Shaders (.shader, .shadergraph)
│   ├── Models/                  # 3D models (.fbx, .obj)
│   └── Textures/                # Textures (.png, .tga)
├── Audio/                       # Audio clips and mixers
│   ├── SFX/
│   ├── Music/
│   └── Mixers/
├── Configs/                     # ScriptableObject instances (.asset)
└── UI/                          # UI sprites, fonts
```

---

## 3. File Naming Conventions

| Asset Type | Prefix / Suffix | Name Pattern | Example |
| :--- | :--- | :--- | :--- |
| **C# Logic** | No prefix | `PascalCase.cs` | `PlayerMover.cs` |
| **C# View** | Suffix `View` | `PascalCaseView.cs` | `HealthBarView.cs` |
| **C# ScriptableObject** | Suffix `Config` | `PascalCaseConfig.cs` | `EnemyStatsConfig.cs` |
| **SO Instance (.asset)** | Category / Name | `PascalCase.asset` | `RuskerFastStats.asset` |
| **URP Material** | Prefix `M_` | `M_<Category>_<Name>.mat` | `M_Floor_Blockout.mat` |
| **Shader** | Prefix `SH_` | `SH_<Name>` | `SH_Dissolve.shadergraph` |
| **Texture** | Prefix `T_` | `T_<Name>_<Channel>.png` | `T_Cookie_BaseColor.png` |
| **Scene** | Type prefix | `<Type>_<Name>.unity` | `Gameplay_Arena.unity` |
| **Sound Effect** | Prefix `sfx_` | `sfx_<event>.wav` | `sfx_sword_hit.wav` |
| **Music Track** | Prefix `mus_` | `mus_<theme>.mp3` | `mus_combat_wave1.mp3` |

---

## 4. Compilation via Assembly Definitions (`asmdef`)

1. `Assets/_Project/Develop/Runtime/` contains `_Project.Runtime.asmdef`.
2. `Assets/_Project/Develop/Editor/` contains `_Project.Editor.asmdef` targeted strictly to the `Editor` platform and referencing `_Project.Runtime`.
3. Third-party dependencies are referenced via asmdef references, rather than compiling into the root `Assembly-CSharp.dll`.
