---
paths: ["**/*.cs"]
---

# C# Code Style & Engineering Standards

> Стандарты C# кода для проектов на Unity. Исключают скрытые баги, рассинхрон типов и невалидные состояния.

---

## 1. Структура типа и доступ

1. **Namespace отражает стабильную границу сборки/фичи**:
   - `namespace _Project.Develop.Runtime.Gameplay.Player` (префикс проекта обязателен).
2. **Один тип на файл**: имя файла строго совпадает с именем типа (`PlayerMover.cs` ➔ `public sealed class PlayerMover`).
3. **Порядок членов класса**:
   1. Events
   2. Fields & Constants (`const`, `static readonly`, `[SerializeField] private`, `private`)
   3. Constructors / Initialization
   4. Properties
   5. Unity Lifecycle (`Awake`, `OnEnable`, `Start`, `Update`, `OnDisable`, `OnDestroy`)
   6. Public methods
   7. Protected / Private methods
4. **Запрет `protected` полей**:
   - Поля всегда `private`. Доступ наследников — через `protected` свойства (`protected float Speed => _speed;`). Поля `protected` ломают инкапсуляцию базового класса.
5. **Явные модификаторы доступа**: всегда указывать `public`, `private`, `protected` (кроме членов интерфейсов).

---

## 2. Именование данных

- **Имя идёт от сущности к свойству**: `playerHealth`, `objectMass`, `armorPercent`, `minNumber`, `maxNumber`.  
  *Запрещены формы*: `healthOfPlayer`, `percentOfArmor`, `fromNumber`, `toNumber`.
- **Поля и переменные**:
  - `_camelCase` — приватные поля (`_rigidbody`, `_health`).
  - `camelCase` — локальные переменные и параметры (`moveSpeed`, `targetPosition`).
  - `PascalCase` — публичные свойства, методы, структуры, классы.
  - `UPPER_SNAKE_CASE` — константы `const`.
  - `static readonly` — именуются как обычные поля (`_defaultConfig` / `DefaultConfig`), это не `const`.
- **Булевы сущности**: свойства и методы с префиксами `Is`, `Can`, `Has` (`isAlive`, `canAttack`, `hasTarget`). Избегать `checkX` — это скрывает сайд-эффекты.
- **Шаблон `TryX`**: методы, которые могут завершиться неудачей без исключений, возвращают `bool` и отдают результат через `out`:
  ```csharp
  public bool TryGetTarget(out Enemy target)
  ```
- **Имя события — свершившийся факт**: `Damaged`, `ItemAdded`. Обработчик: `OnDamaged`, `OnItemAdded`.
- **Без тавтологий и мусорных суффиксов**: `Character.Move()`, а не `Character.CharacterMove()`. Запрещены `GameManagerController`, `ItemHelperManager`.

---

## 3. Отступы, пробелы и пустые строки (Whitespace)

1. **Правило пустых строк**:
   - **Ровно одна пустая строка** между методами, свойствами, конструкторами и логическими блоками (`if`, `for`, `while`, `switch`). Код не должен слипаться в плотную кашу.
   - **Запрещены пустые строки сразу после `{` и прямо перед `}`**:
     ```csharp
     // Неправильно:
     void TakeDamage()
     {

         _health -= 10;

     }

     // Правильно:
     void TakeDamage()
     {
         _health -= 10;
     }
     ```
   - **Не более одной пустой строки подряд**: две и более пустые строки запрещены во всем файле.
   - **Пустая строка между `case` в `switch`**: каждый блок `case` отделяется для визуальной структуры.
2. **Фигурные скобки всегда на отдельной строке (Allman Style)**:
   - Каждая открывающая `{` и закрывающая `}` скобка находится на отдельной строке с одинаковым уровнем отступа:
     ```csharp
     if (isGrounded)
     {
         Jump();
     }
     ```
   - Запрещено лепить код в одну строку со скобками: `if (x) { Do(); }`.
3. **Объявление переменных**:
   - Запрещено объявлять несколько переменных через запятую в одной строке (`int a = 1, b = 2;`). Каждая переменная объявляется на своей строке.
4. **Пробелы вокруг операторов**:
   - Пробелы обязательны вокруг операторов присваивания и бинарных операций: `a = b + c;` (не `a=b+c;`).
   - Пробел после ключевых слов управления: `if (condition)`, `while (isRunning)`, `switch (state)` (пробел между словом и скобкой).
5. **Длина строки и переносы**:
   - Длина строки не должна превышать 120 символов (код читается без горизонтальной прокрутки).
   - Длинные параметры методов и цепочки LINQ переносятся на новую строку с отступом в 4 пробела.

---

## 4. Языковые конструкции и контракты

1. **Явные типы вместо `var`**:
   - `int count = 10;`, `Enemy enemy = GetComponent<Enemy>();`.
   - `var` допустим только когда тип буквально повторен справа (`Transform t = new Transform();` или длинные дженерики `Dictionary<int, List<Transform>> map = new();`).
2. **Явная проверка на ложь**:
   - `if (isAlive == false)` вместо `if (!isAlive)` — восклицательный знак легко потерять при беглом чтении дифа.
3. **Чистые геттеры (Pure Getters)**:
   - Геттеры свойств и методы-инспекторы никогда не должны изменять внутреннее состояние объекта или порождать сайд-эффекты.
4. **Контракт возврата: `return` против `ref/out`**:
   - Если метод вычисляет одно значение — возвращать его через `return`, а не мутировать входящий `ref/out`.
5. **Разграничение исключений**:
   - `ArgumentException` / `ArgumentNullException` / `ArgumentOutOfRangeException` — только при невалидных входных аргументах метода.
   - `InvalidOperationException` — если аргументы верны, но текущее состояние объекта не позволяет операцию (выстрел из незаряженного оружия, старт уже работающего таймера).
6. **Верхняя граница `Random.Next(min, max)`**:
   - Верхняя граница в `System.Random.Next` эксклюзивна (не включается). Для значений 1..10 писать `random.Next(1, 11)`.
7. **Ввод через цикл, а не рекурсию**:
   - Ожидание валидного ввода или состояния делается циклом (`while`), а не рекурсивным перезапуском метода (защита от `StackOverflowException`).

---

## 5. Асинхронный код (UniTask)

1. **Только `UniTask` в Unity**:
   - Использовать `UniTask`, `UniTask<T>`, `UniTaskVoid`.
   - Запрещен `System.Threading.Tasks.Task` (порождает аллокации в куче на главном потоке движка).
2. **Суффикс `Async` обязателен**:
   - Любой метод, возвращающий `UniTask` / `UniTask<T>` / `UniTaskVoid`, оканчивается на `Async` (`ReloadGunAsync`).
3. **Запрет `async void`**:
   - `async void` запрещен, кроме обработчиков Unity UI событий (`button.onClick`). В таких обработчиках тело обязано быть внутри `try-catch`.
   - Для fire-and-forget из обычных методов использовать `UniTaskVoid` и метод `.Forget()`.
4. **CancellationToken**:
   - Передавать `CancellationToken cancellationToken = default` последним параметром и пробрасывать во вложенные вызовы. В MonoBehaviour связывать с `destroyCancellationToken`.
