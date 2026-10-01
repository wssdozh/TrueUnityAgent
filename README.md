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
  <img src="https://img.shields.io/badge/починка-первопричина-111111?style=flat-square" alt="Только первопричина">
  <img src="https://img.shields.io/badge/UI-контракт%2095%25-111111?style=flat-square" alt="Контракт UI 95%">
  <img src="https://img.shields.io/badge/лицензия-MIT-111111?style=flat-square" alt="Лицензия MIT">
</p>

---

Просишь ИИ сделать простой кулдаун выстрела.  
В ответ он заводит `ShotCooldownManager`, вешает `Update()` с тиками, интерфейс `IShotCooldownService`, шину событий и ScriptableObject.

`true-unity-agent` заставляет агента писать минимальный рабочий код без архитектурного раздутия и костылей.

---

## Было / Стало

### 1. Кулдаун выстрела
Обычный агент городит корутину с аллокациями в куче:
```csharp
StartCoroutine(CooldownRoutine());
IEnumerator CooldownRoutine() {
    yield return new WaitForSeconds(0.5f); // аллокация GC на каждый вызов
    _canShoot = true;
}
```
С `true-unity-agent` — один float, ноль мусора в памяти:
```csharp
if (Time.time < _nextFireTime) return;
_nextFireTime = Time.time + COOLDOWN;
```

### 2. Проверка дистанции
Обычный агент считает корень в `Update` каждый кадр:
```csharp
if (Vector3.Distance(transform.position, target.position) <= attackRange)
```
С `true-unity-agent` — скалярное сравнение квадратов:
```csharp
if ((transform.position - target.position).sqrMagnitude <= attackRange * attackRange)
```

### 3. Компонент при коллизии
Обычный агент делает слепой поиск и плодит `NullReferenceException`:
```csharp
var health = other.GetComponent<Health>();
if (health != null) health.TakeDamage(10);
```
С `true-unity-agent` — без аллокаций и безопасно:
```csharp
if (other.TryGetComponent(out Health health)) health.TakeDamage(10);
```

---

## Быстрый старт за 10 секунд

### 1. Установи правила в проект
Выполни команду в PowerShell, указав путь к корню своего Unity-проекта:

```powershell
.\install.ps1 -TargetPath "C:\Путь\К\Твоему\UnityПроекту"
```
*(Либо подключи как submodule: `git submodule add https://github.com/wssdozh/true-unity-agent.git .agents`)*

### 2. Запусти адаптацию
Открой чат с агентом (DSH / Claude Code / Cursor) в своем проекте и отправь одну строку:

```text
Прочитай START.md и адаптируй контекст под этот проект.
```

Агент сам прочитает `manifest.json`, определит стек (URP, Input System, UniTask, DI/ECS), разметит карту папок и запишет актуальный контекст в `AGENTS.md`.

---

## Как это работает: Лестница Ponytail

Перед тем как написать строчку кода, агент останавливается на самой нижней рабочей ступени:

```text
1. Этому вообще нужно существовать? → Нет: выкидываем (YAGNI)
2. Уже есть в проекте?               → Переиспользуем, а не пишем заново
3. Умеет стандартная библиотека?    → Берём Mathf, Span<T>, System.Collections
4. Умеет сама Unity?                 → Берём Physics, NavMesh, URP, Input System
5. Умеет установленный пакет?       → Берём UniTask, PrimeTween
6. Можно решить в одну строку?       → Решаем в одну строку
7. Только если ничего не подошло    → Пишем минимум необходимого кода
```

- **Чинить первопричину, а не симптомы**: проверки `if (x != null)` по десяти местам и пустые `try/catch` запрещены. Проблема устраняется один раз в источнике данных.
- **Объяснение длиннее кода? Сотри объяснение**: код говорит сам за себя.
- **Пометка компромиссов (`// ponytail:`)**: при осознанном выборе простого алгоритма оставляется комментарий с порогом переделки (`// ponytail: переписать на Spatial Grid при N > 300`).

---

## Модули правил (`rules/`)

| Файл | Область | Что делает |
| :--- | :--- | :--- |
| [`readiness-and-delivery.md`](./rules/readiness-and-delivery.md) | **Workflow** | Feature Gate ($\ge 90\%$), опрос `ask_user_question`, автономная доставка, DoD. |
| [`anti-deadlock.md`](./rules/anti-deadlock.md) | **Workflow** | Лестница Ponytail, поиск первопричины (No Crutches), лимит 3 попыток. |
| [`git-workflow.md`](./rules/git-workflow.md) | **Workflow** | Ветки (`feature/*`, `fix/*`), целостность `.meta`, Conventional Commits на английском. |
| [`code-style.md`](./rules/code-style.md) | **Engineering** | Именование `playerHealth`, явные типы вместо `var`, чистые геттеры, UniTask. |
| [`architecture-design.md`](./rules/architecture-design.md) | **Engineering** | Factory отдельно от Spawner, Single State Owner, доменные модели, ISP, Entry Point. |
| [`unity-best-practices.md`](./rules/unity-best-practices.md) | **Engineering** | ScriptableObject неизменяем в рантайме, сброс пула, изоляция Animator, `sqrMagnitude`. |
| [`ui-toolkit-pipeline.md`](./rules/ui-toolkit-pipeline.md) | **Tools** | Двухэтапный UI пайплайн (HTML в браузере ➔ Unity), контракт вёрстки 95%, retained-mode. |
| [`unity-cli.md`](./rules/unity-cli.md) | **Tools** | Запрет правки YAML сцен/префабов как текст. Команды `unity command`, цикл `unity recompile`. |
| [`project-structure.md`](./rules/project-structure.md) | **Tools** | Zero Junk Policy (`Assets/_Project/`), префиксы ассетов, изоляция через `asmdef`. |

---

## Лицензия

[MIT](LICENSE) © [wssdozh](https://github.com/wssdozh)
