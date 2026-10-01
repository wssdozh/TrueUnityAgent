---
paths: ["Assets/**/*.uxml", "Assets/**/*.uss", "Assets/**/*UI*.cs"]
---

# UI Interface Pipeline: UI Toolkit

> Standards for building game UI with UI Toolkit in Unity 6+.  
> Eliminates visual rework and ensures fidelity to approved designs.

---

## 1. Two-Gate Pipeline

Building interfaces blindly directly in Unity produces dozens of unnecessary recompilation cycles and tedious manual tweaking. UI workflow follows 2 strict stages:

1. **Gate 1: Interactive HTML/CSS prototype in browser**:
   - Screen mockup is implemented in vanilla HTML/CSS/JS in a standalone local `.html` file.
   - Demonstrates true aspect ratios, palette, typography, icons, and button interactive states (`:hover`, `:active`, `:disabled`).
   - Human inspects and approves appearance, layout composition, and visual tone.
   - Transferring assets to Unity prior to HTML prototype approval is prohibited.
2. **Gate 2: Transfer to Unity UI Toolkit**:
   - Transfer DOM hierarchy into `UXML`.
   - Transfer CSS rules into `USS`.
   - Bind commands, event listeners, and data flow in C#.

---

## 2. Layout Fidelity Contract (95% Fidelity)

- Approved mockups and HTML prototypes serve as binding contracts:
  - Placement, dimensions, scaling, proportions, and element alignment must reproduce the prototype with at least **95% fidelity**.
- Adding unrequested tooltips, decorative badges, extra labels, or controls not present in the approved design is prohibited.
- If the agent believes an extra UI element is needed, obtain approval prior to implementation.

---

## 3. UI Toolkit Architectural Separation

1. **UXML (Structure)**:
   - Contains strictly the visual element hierarchy (`VisualElement`, `Button`, `Label`).
   - Visual styling lives in USS; inline styles are prohibited.
2. **USS (Styles & Design Tokens)**:
   - Semantic color palettes, margins, padding, typography, border-radii.
   - Interactive pseudo-classes: `:hover`, `:active`, `:disabled`.
   - Transitions (`transition: scale 0.1s ease-out`).
3. **C# View / Controller (Logic & Commands)**:
   - Event listening on clicks, updating label text, updating progress fill bars.
   - Decoupled from internal domain models.

---

## 4. Retained-Mode Lifecycle in Unity

1. **Initialization in `OnEnable`**:
   - Query elements via `rootVisualElement.Q<Button>("my-button")`.
   - Wire event handlers: `button.clicked += OnButtonClicked`.
2. **Cleanup in `OnDisable`**:
   - Mandatory unsubscription: `button.clicked -= OnButtonClicked`.
3. **Prohibition of polling and rebuilding in `Update()`**:
   - UI Toolkit is a retained-mode framework. Rebuilding element hierarchies or polling state in `Update()` is prohibited.
   - The UI updates strictly in response to domain events (e.g., when `OnHealthChanged(int current)` fires).
