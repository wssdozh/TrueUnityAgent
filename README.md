<p align="center">
  <img src="assets/banner.svg" alt="True Unity Agent" width="760">
</p>

<h1 align="center">True Unity Agent</h1>

<p align="center">
  <em>Видит твой менеджер на 200 строк. Пишет три строки. Компилируется.</em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/unity-6%2B-111111?style=flat-square" alt="Unity 6+">
  <img src="https://img.shields.io/badge/агенты-DSH%20%C2%B7%20Claude%20%C2%B7%20Cursor-111111?style=flat-square" alt="Подходит для агентов">
  <img src="https://img.shields.io/badge/починка-первопричина-111111?style=flat-square" alt="Только первопричина">
  <img src="https://img.shields.io/badge/UI-контракт%2095%25-111111?style=flat-square" alt="Контракт UI 95%">
  <img src="https://img.shields.io/badge/лицензия-MIT-111111?style=flat-square" alt="Лицензия MIT">
</p>

---

Кодекс архитектурных правил, инженерных стандартов и чек-листов для автономных ИИ-агентов (**DeepSeek Harness**, **Claude Code**, **Cursor**, **Windsurf**) в проектах на Unity 6+.

Заставляет агента писать минимальный рабочий C# код, искать первопричины багов вместо расстановки костылей и безопасно управлять редактором через официальный Unity CLI без повреждения файлов сцен и префабов.

---

## Быстрый старт

### 1. Подключи правила к проекту

Запусти установщик в PowerShell, передав путь к корню своего Unity-проекта:

```powershell
.\install.ps1 -TargetPath "C:\Путь\К\Твоему\UnityПроекту"
```

*(Либо подключи как submodule: `git submodule add https://github.com/wssdozh/true-unity-agent.git .agents`)*

Скрипт создаст структуру `.agents/rules/` и положит точки входа: `START.md`, `AGENTS.md`, `CLAUDE.md`, `.cursorrules`.

### 2. Запусти адаптацию контекста

Открой чат с агентом в своем проекте и отправь одну команду:

```text
Прочитай START.md и адаптируй контекст под этот проект.
```

Агент сам прочитает `manifest.json` и `ProjectVersion.txt`, определит стек (URP, Input System, UniTask, DI/ECS), разметит границы папок `Assets/` и запишет готовый рабочий контекст в `AGENTS.md`.

---

## Ключевые стандарты

- **Поиск первопричины (Root-Cause Fix)**  
  Запрещено маскировать баги слепыми проверками `if (x != null)` по десяти местам или пустыми блоками `try/catch`. Проблема исследуется по всему стеку вызовов и устраняется один раз в источнике данных.

- **Лестница простоты Ponytail**  
  Бритва Оккама против оверинжиниринга. Агент ищет решение строго снизу вверх: YAGNI ➔ готовые классы проекта ➔ C# stdlib (`Mathf`, `Span<T>`) ➔ Unity API ➔ установленный пакет ➔ одна строка ➔ и только потом новый код. Никаких пустых абстракций и интерфейсов с одной реализацией.

- **Безопасность YAML и Unity CLI**  
  Жесткий запрет прямого редактирования файлов сцен (`.unity`), префабов (`.prefab`) и ассетов как текст при запущенном редакторе. Управление сценой, добавление компонентов и запекание выполняются через `unity command`.

- **Контракт вёрстки 95% (UI Toolkit)**  
  Двухэтапный пайплайн интерфейса: сначала интерактивный HTML/CSS макет в браузере ➔ аппрув человеком ➔ перенос в UXML/USS. Запрещено выдумывать декоративные плашки, подсказки и кнопки, которых не было на согласованном макете.

- **Zero Junk Policy**  
  Все пользовательские скрипты, сцены и ассеты изолированы строго в `Assets/_Project/`. Именование ресурсов стандартизировано (`M_*`, `T_*`, `sfx_*`), компиляция изолирована через модульные `asmdef`.

---

## Модули правил (`rules/`)

| Модуль | Область | Описание |
| :--- | :--- | :--- |
| [`readiness-and-delivery.md`](./rules/readiness-and-delivery.md) | **Workflow** | Feature Gate ($\ge 90\%$), протокол опроса разработчика, автономная доставка, DoD, Handoff. |
| [`anti-deadlock.md`](./rules/anti-deadlock.md) | **Workflow** | Лестница Ponytail, поиск первопричины (No Crutches), правило 3 попыток против зацикливания. |
| [`git-workflow.md`](./rules/git-workflow.md) | **Workflow** | Стратегия веток (`feature/*`, `fix/*`), целостность парных `.meta` файлов, Conventional Commits. |
| [`code-style.md`](./rules/code-style.md) | **Engineering** | Именование `playerHealth`, явные типы вместо `var`, whitespace (пустые строки, скобки Allman), UniTask. |
| [`architecture-design.md`](./rules/architecture-design.md) | **Engineering** | Factory отдельно от Spawner, Single State Owner, доменные модели, узкие интерфейсы (ISP), Composition Root. |
| [`unity-best-practices.md`](./rules/unity-best-practices.md) | **Engineering** | ScriptableObject неизменяем в рантайме, запрет тихих `return`, контракт сброса пула, изоляция Animator, `sqrMagnitude`. |
| [`ui-toolkit-pipeline.md`](./rules/ui-toolkit-pipeline.md) | **Tools** | Двухэтапный UI пайплайн (HTML в браузере ➔ Unity), контракт вёрстки 95%, retained-mode C#. |
| [`unity-cli.md`](./rules/unity-cli.md) | **Tools** | Запрет правки YAML файлов как текст. Команды `unity command`, цикл перекомпиляции `unity recompile`. |
| [`project-structure.md`](./rules/project-structure.md) | **Tools** | Zero Junk Policy (`Assets/_Project/`), правила префиксов, изоляция сборок через `asmdef`. |

---

## Лицензия

[MIT](LICENSE) © [wssdozh](https://github.com/wssdozh)
