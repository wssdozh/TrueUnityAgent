# ⚔️ true-unity-agent

> **Бескомпромиссный золотой стандарт инструкций, архитектурных правил и чек-листов для автономных ИИ-агентов в Unity 6+.**  
> Совместим с **Claude Code**, **DeepSeek Harness**, **Cursor IDE**, **Windsurf** и **GitHub Copilot**.

Создан разработчиком [@wssdozh](https://github.com/wssdozh) на основе сотен часов реальной практики, разбора критических антипаттернов и автоматизации Unity через CLI.

---

## 💡 Зачем это нужно?

Обычные LLM без жестких правил в Unity совершают одни и те же фатальные ошибки:
- ❌ Напрямую перезаписывают текст `.unity` и `.prefab` файлов, ломая GUID сцены и заставляя Unity падать.
- ❌ Пишут `GameObject` в сериализуемые поля, плодя слепые `GetComponent` по всей игре.
- ❌ Создают бесконечные аллокации `new WaitForSeconds` в корутинах и считают расстояния через тяжёлый `Vector3.Distance`.
- ❌ Загромождают корень `Assets/` мусорными скриптами и временными ассетами без структуры.
- ❌ Зацикливаются на исправлении одной и той же ошибки компиляции, тратя токены и ломая проект.

**`true-unity-agent` полностью решает эти проблемы через модульный кодекс правил.**

---

## 📂 Модульная система правил (`rules/`)

| Модуль | Описание стандарта |
| :--- | :--- |
| 📘 [`code-style.md`](./rules/code-style.md) | **True C#**: явные типы вместо `var`, порядок полей/методов, `_camelCase` приватные поля, `UPPER_SNAKE_CASE` константы, обязательный `UniTask` с суффиксом `Async`, запрет `Task` и `async void`, строгий синтаксис `if (x == false)`. |
| ⚡ [`unity-best-practices.md`](./rules/unity-best-practices.md) | **True Unity**: запрет `GameObject` в сериализации, безальтернативный `TryGetComponent`, расчёт расстояний строго через `sqrMagnitude`, кэширование задержек, обязательный Object Pooling для снарядов/VFX. |
| 🕹️ [`unity-cli.md`](./rules/unity-cli.md) | **True Unity CLI**: жесткий запрет ручной правки YAML сцен/префабов. Управление редактором через `unity command` (`create_gameobject`, `bake_navmesh`, `save_scene`), верификация через `unity recompile` и чтение `unity console`. |
| 🗂️ [`project-structure.md`](./rules/project-structure.md) | **True File & Zero Junk Policy**: весь пользовательский контент изолирован строго в `Assets/_Project/`. Соглашения именования (`M_*`, `T_*`, `SH_*`, `sfx_*`), мгновенная компиляция через модульные Assembly Definitions (`asmdef`). |
| 🎯 [`grill-me.md`](./rules/grill-me.md) | **Pre-flight Interview**: сбор вводных (платформа, стек, масштаб, ограничения) и пошаговый опрос пользователя перед планированием фич. |
| 🛡️ [`anti-deadlock.md`](./rules/anti-deadlock.md) | **Ponytail Ladder**: защита от архитектурного оверинжиниринга (YAGNI, использование стандартных библиотек C# и Unity, минимум абстракций) и «Правило 3 попыток» против бесконечных циклов ошибок. |

---

## 🚀 Как подключить к любому новому Unity-проекту

### Способ 1: Быстрая установка скриптом (Рекомендуется)

Запустите PowerShell-установщик, указав путь к вашему Unity-проекту:

```powershell
# Из этой папки:
.\install.ps1 -TargetPath "C:\Users\morii\Projects\MyNewUnityGame"

# Либо если вы находитесь в корне целевого проекта:
& "C:\Users\morii\OneDrive\Dokumenter\prompts\true-unity-agent\install.ps1"
```

Скрипт автоматически:
1. Создаст папку `.agents/rules/` в целевом проекте.
2. Скопирует все модульные правила.
3. Разместит готовые входные точки: `CLAUDE.md`, `AGENTS.md` и `.cursorrules`.

---

### Способ 2: Через Git Submodule

Если ваш Unity-проект уже является git-репозиторием:

```bash
git submodule add https://github.com/wssdozh/true-unity-agent.git .agents
```

---

### Способ 3: Вручную

Скопируйте содержимое папки `templates/` в корень вашего Unity-проекта:
- `templates/.agents/` ➔ в `.agents/`
- `templates/CLAUDE.md` ➔ в корень проекта
- `templates/AGENTS.md` ➔ в корень проекта
- `templates/.cursorrules` ➔ в корень проекта

---

## 📜 Лицензия

MIT © [wssdozh](https://github.com/wssdozh)
