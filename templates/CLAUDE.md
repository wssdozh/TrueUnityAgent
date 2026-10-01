# CLAUDE.md — Universal Unity Project Agent Guide

> Руководство для Claude Code и автономных ИИ-агентов при работе с проектом на Unity.

---

## Контекст проекта

- **Движок**: Unity 6+ (URP / HDRP)
- **Язык**: C# (явные типы, `_camelCase` приватные поля, `UPPER_SNAKE_CASE` константы)
- **Управление редактором**: Official Unity CLI (`unity`)
- **Асинхронность**: `UniTask` (`UniTask<T>`, `UniTaskVoid`) с обязательным суффиксом `Async`
- **Ввод**: New Input System (`UnityEngine.InputSystem`)

---

## Структура репозитория (Zero Junk Policy)

Весь код и пользовательские ресурсы проекта живут строго в `Assets/_Project/`:
- `Assets/_Project/Develop/Runtime/` — C# скрипты игры, разбитые по фичам
- `Assets/_Project/Develop/Editor/` — Editor-only тулы и скрипты
- `Assets/_Project/Scenes/` — Сцены (`_Core/`, `Gameplay/`, `Sandboxes/`)
- `Assets/_Project/Prefabs/` — Префабы сущностей, окружения, UI
- `Assets/_Project/Art/` — Материалы (`M_*`), шейдеры, модели, текстуры

---

## Навигация по правилам (`.agents/rules/`)

Перед выполнением задач обращайся к профильным правилам:
1. **Пишешь C# код?** ➔ читай `.agents/rules/code-style.md`
2. **Пишешь Unity-логику или физику?** ➔ читай `.agents/rules/unity-best-practices.md`
3. **Управляешь сценами или компиляцией?** ➔ читай `.agents/rules/unity-cli.md` (никакого ручного редактирования YAML сцен!)
4. **Создаешь новые файлы или структуру?** ➔ читай `.agents/rules/project-structure.md`
5. **Планируешь механику?** ➔ запускай интервью по `.agents/rules/grill-me.md`
6. **Застрял на ошибке?** ➔ следуй протоколу `.agents/rules/anti-deadlock.md` (правило 3 попыток, Ponytail)
7. **Делаешь коммиты или ветки?** ➔ читай `.agents/rules/git-workflow.md` (сохранность `.meta`, Conventional Commits на английском)

---

## Рабочий цикл агента

1. **Перед кодингом**: собери вводные (платформа, стек, масштабы) и согласуй развилки.
2. **Во время работы со сценой**: проверяй `unity status`. Если редактор активен — управляй через `unity command`.
3. **После написания C# кода**:
   - Вызови `unity recompile --project-path .`
   - Проверь ошибки: `unity command console --level error --tail 20`
4. **Коммиты**: атомарные, осмысленные, на английском языке по стандарту Conventional Commits (`feat:`, `fix:`, `refactor:`, `chore:`).
