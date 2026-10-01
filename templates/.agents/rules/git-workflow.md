---
paths: [".git/**", "**/*"]
---

# Правила работы с Git в Unity

> Стандарты работы с ветками, коммитами и файлами метаданных в Unity-проектах.  
> Исключают потерю данных, конфликты слияния и рассинхрон GUID.

---

## 1. Структура веток (Branching Strategy)

- **`main`** — стабильная ветка проекта. Код обязан компилироваться и проходить тесты.
- **`feature/<name>`** — разработка новой фичи или механики (`feature/player-dash`).
- **`fix/<name>`** — исправление конкретного бага (`fix/navmesh-obstacle-carve`).
- **`chore/<name>`** — обновление пакетов, тулинг, настройки проекта (`chore/update-packages`).
- **`backup/<name>`** — страховочные ветки перед крупными миграциями версий или очисткой LFS.

---

## 2. Специфика Unity в Git

1. **Неразрывность ассета и `.meta` файла**:
   * Любой файл или папка в `Assets/` имеет парный файл `.meta` с уникальным GUID.
   * Запрещено коммитить `.cs`, `.prefab` или `.asset` без соответствующего `.meta` файла (и наоборот).
   * Удаление или переименование файла обязано сопровождаться удалением или переименованием его `.meta`.
2. **Исключение временных файлов**:
   * В `.gitignore` исключаются: `Library/`, `Temp/`, `Logs/`, `UserSettings/`, `MemoryCaptures/`, `Recordings/`, `Build/`, `.vs/`, `.idea/`.
3. **Git LFS для бинарных ассетов**:
   * Текстуры (`.png`, `.tga`, `.psd`), 3D-модели (`.fbx`, `.obj`), аудио (`.wav`, `.mp3`) и видео (`.mp4`) отслеживаются через Git LFS (`git lfs track "*.fbx"`).
4. **Запрет `push --force` в `main`**.

---

## 3. Стандарт сообщений коммитов (Conventional Commits)

Все сообщения коммитов пишутся на английском языке, кратко и в повелительном наклонении:

`type(scope): imperative description`

### Типы:
- **`feat`**: новая механика, компонент или система (`feat(combat): implement toothpick thrust spherecast`)
- **`fix`**: исправление бага или ошибки компиляции (`fix(camera): correct trauma shake decay formula`)
- **`refactor`**: изменение структуры кода без изменения игрового поведения (`refactor(enemy): decouple steering from brain`)
- **`perf`**: оптимизация памяти, пулинга или вызовов (`perf(pool): preallocate shatter shard rigidbodies`)
- **`chore`**: правка конфигов, пакетов `manifest.json`, метаданных или правил агента (`chore(agents): add git workflow rule`)
- **`docs`**: обновление README, GDD или документации архитектуры (`docs(gdd): add arena dimension specs`)

---

## 4. Чек-лист перед слиянием (Pre-Merge Checklist)

Перед слиянием feature-ветки или пушем в `main`:
1. `unity recompile --project-path .` — компиляция завершилась без ошибок.
2. `git status` — нет потерянных или не отслеживаемых `.meta` файлов.
3. `unity command console --level error` — в консоли редактора нет критических ошибок и исключений.
