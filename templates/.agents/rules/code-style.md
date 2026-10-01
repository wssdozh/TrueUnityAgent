---
paths: ["**/*.cs"]
---

# C# Code Style & Quality Standards (True C#)

> **Стандарт чистого кода для автономных ИИ-агентов в проектах на Unity / C#.**  
> Применяется ко всем `.cs` файлам проекта (кроме автоматически генерируемого кода `Generated/`).

---

## 1. Структура файла и класса

1. **Namespace строго отражает путь к папке**:
   - `Assets/_Project/Develop/Runtime/Gameplay/Player/` ➔ `namespace _Project.Develop.Runtime.Gameplay.Player`
   - Единый корневой префикс проекта обязателен (например, `_Project`).
2. **Один класс/интерфейс/структура на файл**:
   - Имя файла строго совпадает с именем типа (`PlayerMover.cs` ➔ `public sealed class PlayerMover`).
3. **Строгий порядок членов типа**:
   1. События (`event Action Damaged`)
   2. Поля и константы (`const`, `static readonly`, поля инспектора, приватные поля)
   3. Конструкторы
   4. Свойства (`public float Speed { get; private set; }`)
   5. Методы жизненного цикла Unity (`Awake`, `OnEnable`, `Start`, `Update`, `OnDisable`, `OnDestroy`)
   6. Публичные методы
   7. Защищённые методы (`protected`)
   8. Приватные вспомогательные методы
4. **Внутри каждой группы членов**:
   - Сортировка по модификаторам доступа: `public` ➔ `protected` ➔ `private`.
5. **Явные модификаторы доступа**:
   - Всегда указывать `public`, `private`, `protected`, `internal`.
   - Исключение: члены интерфейса (где модификаторы подразумеваются спецификацией).

---

## 2. Именование (Naming Conventions)

| Категория | Стиль | Примеры | Антипаттерны |
| :--- | :--- | :--- | :--- |
| **Локальные переменные, параметры** | `camelCase` | `moveSpeed`, `targetPosition`, `isAlive` | `MoveSpeed`, `_speed` |
| **Приватные поля экземпляра** | `_camelCase` | `_rigidbody`, `_health`, `_cancellationTokenSource` | `rigidbody`, `m_Health` |
| **Публичные / protected поля** | `PascalCase` | `MaxSpeed`, `DefaultColor` | `maxSpeed`, `_maxSpeed` |
| **Свойства** | `PascalCase` | `CurrentHealth`, `IsGrounded` | `currentHealth`, `health` |
| **Методы** | `PascalCase` | `TakeDamage()`, `TryBuild()`, `Respawn()` | `takeDamage()`, `DoMove()` |
| **Константы (`const`)** | `UPPER_SNAKE_CASE` | `MAX_PLAYERS`, `DEFAULT_TIMEOUT_SEC` | `MaxPlayers`, `c_maxPlayers` |
| **Static readonly поля** | `PascalCase` (pub) / `_camelCase` (priv) | `Empty`, `_defaultConfig` | `DEFAULT_CONFIG` (это не const!) |
| **События (Events)** | `PascalCase` (в прошедшем времени) | `Killed`, `StateChanged`, `AttackTriggered` | `OnKill`, `EventKill` |
| **Обработчики событий** | `On` + ИмяСобытия | `OnKilled()`, `OnHealthChanged(int current)` | `HandleEvent()`, `KillHandler()` |

### Смысловые правила именования:
- **Bool-методы и свойства**: начинать с префиксов `Is`, `Can`, `Has` (`IsEmpty()`, `CanJump()`, `HasTarget`). Избегать `CheckTarget()` — это порождает сайд-эффекты.
- **Шаблон `TryX`**: методы, которые могут завершиться неудачей без выброса исключений, возвращают `bool` и отдают результат через `out`:
  ```csharp
  public bool TryGetTarget(out Enemy target)
  ```
- **Без тавтологий**: пиши `Character.Move()`, а не `Character.CharacterMove()`. На месте вызова и так написано `character.`.
- **Без паразитных слов**: запрещены `GameManagerController`, `ItemHelperManager`, `LogicHandlerExecutor`. Имя обязано выражать единственную ответственность.
- **Множественное число для коллекций**: `coins` — коллекция монет, `coin` — одна монета.

---

## 3. Форматирование и читаемость

1. **Явные типы вместо `var`**:
   - Пиши `int count = 10;`, `Enemy enemy = GetComponent<Enemy>();`.
   - `var` допустим **только** когда тип буквально продублирован справа: `Transform transform = new Transform();` или длинный дженерик `Dictionary<int, List<Transform>> map = new();`.
2. **Проверка на ложь строго явная**:
   - `if (isAlive == false)` вместо `if (!isAlive)`.
   - Восклицательный знак легко не заметить при быстром чтении или ревью дифов.
3. **Правило пустых строк**:
   - **Максимум одна пустая строка подряд**. Две пустые строки запрещены.
   - **Не ставить пустые строки** сразу после открывающей `{` и перед закрывающей `}` фигурной скобкой.
   - **Отделять пустой строкой** блоки `if`, `for`, `foreach`, `switch` от окружающего кода.
   - **Пустая строка между `case`** в конструкции `switch`.

---

## 4. Качество кода и анти-магия

1. **Никаких магических чисел**:
   - Все задержки, радиусы, коэффициенты урона и лимиты выносятся в `const float` или сериализуемые поля конфигов.
   - `0` и `1` допустимы только в тривиальных операциях (индексация, инкремент).
2. **Никаких вычислений и форматирования в сигнатурах логов**:
   - Не делать `Debug.Log($"Val: " + (a * 100 / b));`. Вычисли результат заранее в локальную переменную.
   - В финальном коде перед коммитом не должно оставаться мусорного отладочного спама.
3. **Не создавай старый объект заново**:
   - Метод создания сущности называется `CreateObject()`, а не `CreateNewObject()`. Не бывает "старых" создаваемых объектов.
4. **Валидация аргументов и `null`**:
   - Проверяй входящие параметры в публичных методах:
     ```csharp
     _storage = storage ?? throw new ArgumentNullException(nameof(storage));
     ```
   - Если операция вызвана в невалидный момент жизненного цикла объекта — бросай `InvalidOperationException`, а не `ArgumentOutOfRangeException`.

---

## 5. Асинхронное программирование (UniTask)

1. **Только `UniTask` в Unity**:
   - Использовать `UniTask`, `UniTask<T>`, `UniTaskVoid`.
   - Запрещено использовать `System.Threading.Tasks.Task` (порождает аллокации в куче на главном потоке Unity).
2. **Суффикс `Async` строго обязателен**:
   - Любой метод, возвращающий `UniTask`, `UniTask<T>` или `UniTaskVoid`, обязан заканчиваться на `Async` (`SpawnWaveAsync`, `ReloadGunAsync`).
3. **Запрет `async void`**:
   - `async void` полностью запрещён. Он ломает перехват исключений и крашит процесс.
   - Для fire-and-forget из синхронных методов Unity (`Start`, UI клики) используй `UniTaskVoid`:
     ```csharp
     private void Start()
     {
         InitGameAsync().Forget();
     }
     
     private async UniTaskVoid InitGameAsync() { ... }
     ```
4. **Отмена операций (`CancellationToken`)**:
   - Передавай `CancellationToken cancellationToken = default` последним параметром в любой асинхронный метод.
   - Привязывай токены к жизненному циклу объекта: `destroyCancellationToken` в Unity MonoBehaviour.
