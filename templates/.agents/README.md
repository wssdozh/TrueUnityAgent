# Agent Rules & Instructions Directory (`.agents/`)

В этой папке собраны модульные правила и стандарты для автономных ИИ-агентов (Claude Code, DeepSeek Harness, Cursor, Windsurf):

- [`rules/code-style.md`](./rules/code-style.md) — Стандарты чистого C# кода, именование, UniTask, запрет `var` и магии.
- [`rules/unity-best-practices.md`](./rules/unity-best-practices.md) — Лучшие практики Unity: запрет `GameObject` в сериализации, `TryGetComponent`, `sqrMagnitude`, пулинг.
- [`rules/unity-cli.md`](./rules/unity-cli.md) — Управление через официальный Unity CLI, защита от повреждения YAML файлов сцен и префабов.
- [`rules/project-structure.md`](./rules/project-structure.md) — Zero Junk Policy: организация каталогов в `Assets/_Project/`, именование ассетов, сборки asmdef.
- [`rules/grill-me.md`](./rules/grill-me.md) — Протокол снятия неопределенностей и pre-flight интервью до кодинга.
- [`rules/anti-deadlock.md`](./rules/anti-deadlock.md) — Защита от тупиков, лестница Ponytail (YAGNI), правило 3 попыток.
