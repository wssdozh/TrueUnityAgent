<p align="center">
  <img src="assets/banner.svg" alt="true-unity-agent" width="760">
</p>

<h1 align="center">true-unity-agent</h1>

<p align="center">
  <em>Видит твой менеджер на 200 строк. Пишет три строки. Компилируется.</em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/unity-6%2B-111111?style=flat-square" alt="Unity 6+">
  <img src="https://img.shields.io/badge/агенты-DSH%20%C2%B7%20Claude%20%C2%B7%20Cursor-111111?style=flat-square" alt="Подходит для агентов">
  <img src="https://img.shields.io/badge/починка-только%20первопричина-111111?style=flat-square" alt="Только первопричина">
  <img src="https://img.shields.io/badge/UI-контракт%2095%25-111111?style=flat-square" alt="Контракт UI 95%">
  <img src="https://img.shields.io/badge/лицензия-MIT-111111?style=flat-square" alt="Лицензия MIT">
</p>

---

Знакомая картина: просишь ИИ сделать простой кулдаун выстрела.  
В ответ он заводит `ShotCooldownManager`, вешает `Update()` с тиками, городит интерфейс `IShotCooldownService`, шину событий и ScriptableObject.

`true-unity-agent` вправляет агенту мозги и заставляет писать минимальный рабочий код без архитектурного раздутия.

---

## Было / Стало

### 1. Кулдаун выстрела
Без правил агент пишет корутину на 50 строк с аллокациями в куче:
```csharp
// Типичный мусор нейросети:
StartCoroutine(CooldownRoutine());
IEnumerator CooldownRoutine() {
    yield return new WaitForSeconds(0.5f); // аллокация GC на каждый вызов
    _canShoot = true;
}
```

С `true-unity-agent`:
```csharp
// Один float, ноль мусора в памяти, детерминированно:
if (Time.time < _nextFireTime) return;
_nextFireTime = Time.time + COOLDOWN;
```

### 2. Проверка дистанции
Без правил:
```csharp
// Тяжёлое извлечение корня в Update каждый кадр:
if (Vector3.Distance(transform.position, target.position) <= attackRange)
```

С `true-unity-agent`:
```csharp
// Ноль корней, скалярное сравнение квадратов:
if ((transform.position - target.position).sqrMagnitude <= attackRange * attackRange)
```

### 3. Получение компонента при коллизии
Без правил:
```csharp
// Слепой GetComponent и проверка на null плодят мусор и краши:
var health = other.GetComponent<Health>();
if (health != null) health.TakeDamage(10);
```

С `true-unity-agent`:
```csharp
// Без аллокаций, атомарно и безопасно:
if (other.TryGetComponent(out Health health)) health.TakeDamage(10);
```

---

## Как это работает: Лестница Ponytail

Перед тем как написать хоть строчку, агент обязан остановиться на самой нижней ступени, которая решает задачу:

```text
1. Этому вообще нужно существовать? → Нет: выкидываем (YAGNI)
2. Уже есть в проекте?               → Переиспользуем, а не пишем заново
3. Умеет стандартная библиотека?    → Берём Mathf, Span<T>, System.Collections
4. Умеет сама Unity?                 → Берём Physics, NavMesh, URP, Input System
5. Умеет установленный пакет?       → Берём UniTask, PrimeTween
6. Можно решить в одну строку?       → Решаем в одну строку
7. Только если ничего не подошло    → Пишем минимум необходимого кода
```

### Ключевые принципы:
* **Чинить первопричину, а не замазывать симптомы**: Слепые проверки `if (x != null)` по десяти местам и пустые `try/catch` запрещены. Проблема устраняется один раз в источнике данных.
* **Если объяснение длиннее кода — сотри объяснение**: Любой абзац с оправданием упрощений — это усложнение, протащенное в текст. Код должен быть понятен без простыней текста.
* **Пометка компромиссов (`// ponytail:`)**: Если агент осознанно срезал угол, он оставляет комментарий с порогом переделки:
  ```csharp
  // ponytail: линейный перебор O(N), переписать на Spatial HashGrid при N > 300
  ```

---

## Структура правил (`rules/`)

### 1. Процесс и безопасность (Workflow)
* [`readiness-and-delivery.md`](./rules/readiness-and-delivery.md) — **Регламент и Feature Gate**: Разделение ролей (человек/агент), гейт готовности фичи ($\ge 90\%$), протокол опроса разработчика через `ask_user_question`, автономная доставка без микро-пауз, Cross-Agent Handoff и Definition of Done.
* [`anti-deadlock.md`](./rules/anti-deadlock.md) — **Защита от оверинжиниринга и костылей**: Лестница Ponytail, протокол поиска первопричины (No Crutches), лимит 3 попыток исправления ошибок.
* [`git-workflow.md`](./rules/git-workflow.md) — **Git и безопасность**: Стратегия веток (`feature/*`, `fix/*`, `backup/*`), неразрывность `.meta` файлов, Conventional Commits на английском и чек-лист перед слиянием.

### 2. Код и архитектура (Engineering)
* [`code-style.md`](./rules/code-style.md) — **Стандарты C#**: Именование от сущности к свойству (`playerHealth`), явные типы вместо `var`, приватные поля, чистые геттеры, разделение `ArgumentException` и `InvalidOperationException`, только UniTask.
* [`architecture-design.md`](./rules/architecture-design.md) — **Архитектура и владение**: Фабрика (создание) отдельно от Спавнера (тайминги и позиции), один владелец у каждого состояния, доменные модели вместо анемичных структур, узкие интерфейсы (ISP), Composition Root.
* [`unity-best-practices.md`](./rules/unity-best-practices.md) — **Ошибки и ограничения Unity**: ScriptableObject как строго неизменяемый конфиг в рантайме, запрет тихих `return` при отсутствии ссылок, контракт сброса пула (физика/твины), изоляция Animator, `TryGetComponent`, `sqrMagnitude`.

### 3. Инструменты и ассеты (Tools & Assets)
* [`ui-toolkit-pipeline.md`](./rules/ui-toolkit-pipeline.md) — **Пайплайн интерфейса UI Toolkit**: Двухэтапная работа (интерактивный HTML/CSS макет в браузере ➔ аппрув ➔ перенос в Unity), контракт вёрстки 95% (запрет отсебятины), UXML + USS + retained-mode C#.
* [`unity-cli.md`](./rules/unity-cli.md) — **Управление через Unity CLI**: Запрет прямого редактирования файлов `.unity`/`.prefab` как текст при запущенном редакторе. Управление сценой через `unity command`, цикл перекомпиляции `unity recompile`, диагностика консоли.
* [`project-structure.md`](./rules/project-structure.md) — **Zero Junk Policy**: Всё живёт строго в `Assets/_Project/`. Соглашения об именовании (`M_*`, `T_*`, `SH_*`, `sfx_*`), модульные сборки через `asmdef`.

---

## Быстрое подключение к проекту

### Способ 1. Через PowerShell-скрипт (1 секунда)

Запусти установщик, указав путь к корню своего Unity-проекта:

```powershell
.\install.ps1 -TargetPath "C:\Путь\К\Твоему\UnityПроекту"
```

Скрипт создаст папку `.agents/rules/`, скопирует туда модули и положит готовые файлы конфигурации (`START.md`, `CLAUDE.md`, `AGENTS.md`, `.cursorrules`).

### Способ 2. Через Git Submodule

Если проект уже под гитом:

```bash
git submodule add https://github.com/wssdozh/true-unity-agent.git .agents
```

### Способ 3. Вручную

Скопируй файлы из папки `templates/` в корень своего проекта:
- `templates/.agents/` ➔ в `.agents/`
- `templates/START.md` ➔ в корень
- `templates/AGENTS.md` ➔ в корень
- `templates/CLAUDE.md` ➔ в корень
- `templates/.cursorrules` ➔ в корень

---

## Первый запуск агента в проекте

После того как файлы скопированы, напиши агенту (DSH / Claude / Cursor) одну фразу:

```text
Прочитай START.md и адаптируй контекст под этот проект.
```

Агент сам:
1. Проверит версию Unity (`ProjectVersion.txt`) и стек пакетов (`Packages/manifest.json`).
2. Просканирует папки `Assets/` и границы сборок `.asmdef`.
3. Заполнит реальный стек и карту каталогов в `AGENTS.md` и `CLAUDE.md`.
4. Проверит сборку через `unity recompile`.

---

## Лицензия

[MIT](LICENSE) © [wssdozh](https://github.com/wssdozh)
