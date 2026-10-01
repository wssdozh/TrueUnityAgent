# AGENTS.md — Master Agent Instructions (Unity Template)

> **Стандарт автономного агента для проектов на Unity 6+.**  
> Модульные правила вынесены в директорию `.agents/rules/`.

---

## 🧭 Навигация по правилам (`.agents/rules/`)

| Задача агента | Модуль правил | Главные требования |
| :--- | :--- | :--- |
| **C# кодинг** | [`.agents/rules/code-style.md`](./.agents/rules/code-style.md) | Явные типы, `_camelCase` для приватных полей, `UPPER_SNAKE_CASE` константы, `UniTask` вместо `Task`, `if (x == false)`. |
| **Unity логика & Память** | [`.agents/rules/unity-best-practices.md`](./.agents/rules/unity-best-practices.md) | Запрет типа `GameObject` в сериализации (только конкретные компоненты), `TryGetComponent`, `sqrMagnitude`, пулинг. |
| **Unity CLI & Редактор** | [`.agents/rules/unity-cli.md`](./.agents/rules/unity-cli.md) | **Запрет слепого редактирования .unity/.prefab YAML!** Управление через `unity command`, проверка `unity status`. |
| **Файлы & Организация** | [`.agents/rules/project-structure.md`](./.agents/rules/project-structure.md) | Zero Junk Policy: всё в `Assets/_Project/`. Именование ассетов (`M_`, `T_`, `SH_`, `sfx_`), разделение через asmdef. |
| **Планирование & Архитектура** | [`.agents/rules/grill-me.md`](./.agents/rules/grill-me.md) | Pre-flight интервью (платформа, стек, числа) перед написанием кода. Опрос через варианты решения. |
| **Предотвращение тупиков** | [`.agents/rules/anti-deadlock.md`](./.agents/rules/anti-deadlock.md) | Лестница Ponytail (YAGNI, stdlib, минимум сущностей), лимит 3 попыток исправления ошибок. |

---

## ⚡ Принцип Ponytail (Защита от оверинжиниринга)

1. **YAGNI**: не пиши код на гипотетическое будущее.
2. **Используй готовое**: Unity API и C# stdlib уже содержат решение.
3. **Один класс с одной задачей** лучше, чем пять уровней фабрик и интерфейсов.
4. **Код ➔ Перекомпиляция ➔ Проверка**: ни строчки непроверенного кода.
