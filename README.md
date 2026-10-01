# true-unity-agent

Инструкции, архитектурные правила и шаблоны для автономных агентов (Claude Code, DeepSeek Harness, Cursor, Windsurf) в проектах на Unity 6+.

Репозиторий предотвращает скрытые баги и хаос: запрещает ручную порчу YAML сцен/префабов, блокирует выдумывание геймдизайна агентом, изолирует UI-разработку и исключает накопление костылей.

---

## Что внутри (`rules/`)

### 1. Процесс и безопасность (Workflow)
* [`readiness-and-delivery.md`](./rules/readiness-and-delivery.md) — **Регламент и Feature Gate**: разграничение ролей (человек/агент), обязательный Feature Readiness Gate ($\ge 90\%$), протокол интервью, автономная доставка без простоев, Cross-Agent Handoff и Definition of Done.
* [`anti-deadlock.md`](./rules/anti-deadlock.md) — **Защита от оверинжиниринга и костылей**: 7-ступенчатая лестница Ponytail (YAGNI, использование готового API), протокол поиска первопричины (No Crutches Policy), лимит 3 попыток исправления ошибок.
* [`git-workflow.md`](./rules/git-workflow.md) — **Git и безопасность**: стратегия веток (`feature/*`, `fix/*`, `backup/*`), защита парных `.meta`-файлов, Conventional Commits на английском и пре-мерж проверки.

### 2. Код и архитектура (Engineering)
* [`code-style.md`](./rules/code-style.md) — **C# код-стайл**: именование от сущности к свойству (`playerHealth`), явные типы вместо `var`, приватные поля `_camelCase`, чистые геттеры, разграничение `ArgumentException` и `InvalidOperationException`, асинхронность только на `UniTask`.
* [`architecture-design.md`](./rules/architecture-design.md) — **Архитектура и владение**: разделение Factory (создание) и Spawner (тайминги/позиции), Single State Owner, доменные модели вместо анемичных структур, узкие интерфейсы (ISP), Composition Root.
* [`unity-best-practices.md`](./rules/unity-best-practices.md) — **Практики Unity**: `ScriptableObject` как строго неизменяемый конфиг в рантайме, запрет тихих `return` для обязательных ссылок, контракт сброса пула (физика/твины), изоляция Animator, `TryGetComponent`, `sqrMagnitude`.

### 3. Инструменты и ассеты (Tools & Assets)
* [`ui-toolkit-pipeline.md`](./rules/ui-toolkit-pipeline.md) — **UI Toolkit пайплайн**: 2-этапное согласование (интерактивный HTML/CSS макет в браузере ➔ аппрув ➔ перенос в Unity), Layout-контракт 95%, UXML + USS + retained-mode C#.
* [`unity-cli.md`](./rules/unity-cli.md) — **Работа с редактором**: запрет править `.unity` и `.prefab` руками как текст. Сборка сцены через `unity command`, проверка через `unity recompile` и мониторинг ошибок в консоли редактора.
* [`project-structure.md`](./rules/project-structure.md) — **Структура файлов**: Zero Junk Policy — весь пользовательский код и ассеты живут строго в `Assets/_Project/`. Именование материалов (`M_*`), шейдеров (`SH_*`), звуков (`sfx_*`), изоляция сборок через `asmdef`.

---

## Подключение к проекту

### Вариант 1. Через PowerShell-скрипт

Запустить установщик из репозитория и передать путь к папке игры:

```powershell
.\install.ps1 -TargetPath "C:\Path\To\UnityProject"
```

Скрипт создаст папку `.agents/rules/`, скопирует туда правила и положит готовые файлы конфигурации (`CLAUDE.md`, `AGENTS.md`, `.cursorrules`) в корень проекта.

### Вариант 2. Через Git Submodule

Если проект уже под гитом:

```bash
git submodule add https://github.com/wssdozh/true-unity-agent.git .agents
```

### Вариант 3. Вручную

Скопировать файлы из папки `templates/` в корень своего проекта:
- `templates/.agents/` ➔ в `.agents/`
- `templates/CLAUDE.md` ➔ в корень
- `templates/AGENTS.md` ➔ в корень
- `templates/.cursorrules` ➔ в корень

---

## Первый запуск агента в новом проекте

После того как файлы скопированы в проект, отправьте агенту (DSH / Claude / Cursor) одну команду:

```text
Прочитай START.md и адаптируй контекст под этот проект.
```

Агент автономно:
1. Определит версию Unity (`ProjectVersion.txt`) и установленный стек (`Packages/manifest.json`: URP, Input, UniTask, ECS/DI).
2. Просканирует структуру папок `Assets/` и границы сборок `.asmdef`.
3. Заполнит реальную карту каталогов и стек в `AGENTS.md` (и `CLAUDE.md`).
4. Проверит компиляцию через `unity recompile`.

---

## Лицензия

MIT © [wssdozh](https://github.com/wssdozh)
