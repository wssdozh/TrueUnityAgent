# AGENTS.md — Master Agent Instructions (Unity Template)

> Инструкции для автономных ИИ-агентов в проекте на Unity 6+.  
> Все правила модульно разнесены по каталогу `.agents/rules/`.

---

## Маршрутизация по правилам (`.agents/rules/`)

### 1. Процесс и безопасность (Workflow)
- **Согласование и приёмка фичи** ➔ [`.agents/rules/readiness-and-delivery.md`](./.agents/rules/readiness-and-delivery.md): разделение ролей (человек/агент), Feature Readiness Gate ($\ge 90\%$), протокол интервью, автономная доставка, Cross-Agent Handoff, Definition of Done.
- **Ошибки и оверинжиниринг** ➔ [`.agents/rules/anti-deadlock.md`](./.agents/rules/anti-deadlock.md): лестница простоты Ponytail (YAGNI, stdlib, минимум сущностей), протокол поиска первопричины вместо костылей, правило 3 попыток.
- **Git и ветки** ➔ [`.agents/rules/git-workflow.md`](./.agents/rules/git-workflow.md): стратегия веток (`feature/*`, `fix/*`, `backup/*`), неразрывность `.meta` файлов, Conventional Commits на английском.

### 2. Код и архитектура (Engineering)
- **Стиль C#** ➔ [`.agents/rules/code-style.md`](./.agents/rules/code-style.md): именование от сущности к свойству (`playerHealth`), явные типы вместо `var`, чистые геттеры, `ArgumentException` vs `InvalidOperationException`, UniTask.
- **Архитектура и владение** ➔ [`.agents/rules/architecture-design.md`](./.agents/rules/architecture-design.md): разделение Factory и Spawner, Single State Owner, доменные модели вместо анемичных структур, узкие интерфейсы (ISP), Composition Root.
- **Специфика Unity** ➔ [`.agents/rules/unity-best-practices.md`](./.agents/rules/unity-best-practices.md): неизменяемость ScriptableObject в рантайме, запрет тихих `return`, контракт сброса пула (физика/твины), изоляция Animator, `TryGetComponent`, `sqrMagnitude`.

### 3. Инструменты и ассеты (Tools & Assets)
- **Интерфейс (UI Toolkit)** ➔ [`.agents/rules/ui-toolkit-pipeline.md`](./.agents/rules/ui-toolkit-pipeline.md): двухэтапный пайплайн (HTML/CSS макет в браузере ➔ аппрув ➔ перенос в Unity), Layout-контракт 95%, UXML + USS + retained-mode.
- **Управление редактором** ➔ [`.agents/rules/unity-cli.md`](./.agents/rules/unity-cli.md): запрет редактирования файлов `.unity`/`.prefab` как текст при запущенном редакторе. Команды `unity command`, цикл `unity recompile`, чтение логов.
- **Структура файлов** ➔ [`.agents/rules/project-structure.md`](./.agents/rules/project-structure.md): Zero Junk Policy — все пользовательские файлы строго внутри `Assets/_Project/`, именование ассетов, изоляция сборок через `asmdef`.

---

## Защита от оверинжиниринга (принцип Ponytail)

1. **YAGNI**: не пиши код на гипотетическое будущее.
2. **Используй готовое**: Unity API и C# stdlib уже содержат решение.
3. **Один класс с одной задачей** лучше, чем пять уровней фабрик и интерфейсов.
4. **Код ➔ Перекомпиляция ➔ Проверка**: ни строчки непроверенного кода.
