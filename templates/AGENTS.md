# AGENTS.md — Master Agent Instructions (Unity Template)

> **Стандарт автономного агента для проектов на Unity 6+.**  
> Модульные правила вынесены в директорию `.agents/rules/`.

---

## Навигация по правилам (`.agents/rules/`)

| Задача агента | Модуль правил | Главные требования |
| :--- | :--- | :--- |
| **Регламент и приёмка** | [`.agents/rules/readiness-and-delivery.md`](./.agents/rules/readiness-and-delivery.md) | Роли (Человек/Агент), Feature Readiness Gate ($\ge 90\%$), автономная доставка без простоев, Cross-Agent Handoff, Definition of Done. |
| **C# кодинг** | [`.agents/rules/code-style.md`](./.agents/rules/code-style.md) | Явные типы, `_camelCase` приватные поля, `UPPER_SNAKE_CASE` константы, UniTask, чистые геттеры, разграничение Argument vs InvalidOperation. |
| **Архитектура & Владение** | [`.agents/rules/architecture-design.md`](./.agents/rules/architecture-design.md) | Factory vs Spawner, Single State Owner, доменные модели вместо анемичных структур, узкие интерфейсы (ISP), Composition Root. |
| **Unity логика & Память** | [`.agents/rules/unity-best-practices.md`](./.agents/rules/unity-best-practices.md) | Неизменяемость ScriptableObject, запрет тихих `return`, контракт сброса пула, изоляция Animator, `TryGetComponent`, `sqrMagnitude`. |
| **Интерфейс (UI Toolkit)** | [`.agents/rules/ui-toolkit-pipeline.md`](./.agents/rules/ui-toolkit-pipeline.md) | 2-этапный пайплайн: сначала HTML/CSS макет в браузере ➔ аппрув ➔ перенос в UXML/USS. Layout-контракт 95%, retained-mode. |
| **Unity CLI & Редактор** | [`.agents/rules/unity-cli.md`](./.agents/rules/unity-cli.md) | **Запрет слепого редактирования .unity/.prefab YAML!** Управление через `unity command`, цикл `unity recompile` и чтение `unity console`. |
| **Файлы & Организация** | [`.agents/rules/project-structure.md`](./.agents/rules/project-structure.md) | Zero Junk Policy: всё в `Assets/_Project/`. Именование ассетов (`M_`, `T_`, `SH_`, `sfx_`), разделение сборок через `asmdef`. |
| **Предотвращение тупиков** | [`.agents/rules/anti-deadlock.md`](./.agents/rules/anti-deadlock.md) | Лестница Ponytail (YAGNI, stdlib, минимум сущностей), протокол поиска первопричины вместо костылей, правило 3 попыток. |
| **Git & Безопасность** | [`.agents/rules/git-workflow.md`](./.agents/rules/git-workflow.md) | Ветки (`feature/*`, `fix/*`, `backup/*`), неразрывность `.meta` файлов, Conventional Commits на английском языке. |
| **Планирование фич** | [`.agents/rules/grill-me.md`](./.agents/rules/grill-me.md) | Pre-flight опрос по развилкам перед проектированием. |

---

## Защита от оверинжиниринга (принцип Ponytail)

1. **YAGNI**: не пиши код на гипотетическое будущее.
2. **Используй готовое**: Unity API и C# stdlib уже содержат решение.
3. **Один класс с одной задачей** лучше, чем пять уровней фабрик и интерфейсов.
4. **Код ➔ Перекомпиляция ➔ Проверка**: ни строчки непроверенного кода.
