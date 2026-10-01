# true-unity-agent

Инструкции, правила кода и шаблоны для автономных агентов (Claude Code, DeepSeek Harness, Cursor, Windsurf) в проектах на Unity 6+.

Репозиторий решает частые проблемы, когда агент работает с Unity напрямую: ломает сцены и префабы ручной правкой YAML, плодит слепые `GetComponent`, забивает кучу аллокациями и зацикливается на ошибках компиляции.

---

## Что внутри (`rules/`)

| Файл | Назначение |
| :--- | :--- |
| [`code-style.md`](./rules/code-style.md) | **C# код-стайл**: явные типы вместо `var`, приватные поля `_camelCase`, константы `UPPER_SNAKE_CASE`, асинхронность только на `UniTask` с суффиксом `Async` (без `Task` и `async void`), явная проверка `if (x == false)`. |
| [`unity-best-practices.md`](./rules/unity-best-practices.md) | **Практики Unity**: запрет `GameObject` в сериализации (ссылаемся сразу на нужный компонент), `TryGetComponent` вместо `GetComponent`, проверка дистанций через `sqrMagnitude`, пулинг для спавна и кэш задержек. |
| [`unity-cli.md`](./rules/unity-cli.md) | **Работа с редактором**: запрет править `.unity` и `.prefab` руками как текст. Сборка сцены и спавн через `unity command`, проверка через `unity recompile` и чтение ошибок из консоли редактора. |
| [`project-structure.md`](./rules/project-structure.md) | **Структура файлов**: весь пользовательский код и ассеты живут строго в `Assets/_Project/`. Именование материалов (`M_*`), шейдеров (`SH_*`), звуков (`sfx_*`), изоляция сборок через `asmdef`. |
| [`grill-me.md`](./rules/grill-me.md) | **Чек-лист перед кодом**: сбор вводных (платформа, стек, объемы в рантайме) и уточнение развилок у разработчика до написания классов. |
| [`anti-deadlock.md`](./rules/anti-deadlock.md) | **Защита от оверинжиниринга**: YAGNI, использование готового Unity API и C# stdlib вместо велосипедов, лимит 3 попыток исправления ошибок сборки. |

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

## Лицензия

MIT © [wssdozh](https://github.com/wssdozh)
