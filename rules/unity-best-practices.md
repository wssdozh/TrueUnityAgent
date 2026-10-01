---
paths: ["**/*.cs", "**/*.unity", "**/*.prefab"]
---

# Ошибки и ограничения Unity: память, ссылки и сериализация

> Специфика работы с компонентами, жизненным циклом и памятью Unity.

---

## 1. Сериализация и зависимости компонентов

1. **Запрет типа `GameObject` в сериализации**:
   - `[SerializeField] private CharacterView _prefab;` вместо `[SerializeField] private GameObject _prefab;`.
   - Поле обязано быть строго типизировано целевым компонентом или `Transform`. Это исключает подсовывание невалидных префабов и убирает лишние `GetComponent` при спавне.
2. **Безальтернативный `TryGetComponent`**:
   - Не использовать слепой `GetComponent` на сторонних объектах. `TryGetComponent` не аллоцирует память в куче и сразу проверяет наличие:
   ```csharp
   if (collider.TryGetComponent(out IDamageable target))
   {
       target.TakeDamage(_damage);
   }
   ```
3. **Запрет тихих `return` при отсутствии обязательных зависимостей**:
   - Не писать `if (_rigidbody == null) return;` внутри `Update()` / `FixedUpdate()` — это маскирует ошибки настройки префабов на сцене.
   - Валидировать ссылки в `Awake()` с явным выбросом исключения или логом ошибки:
   ```csharp
   private void Awake()
   {
       if (TryGetComponent(out _rigidbody) == false)
       {
           throw new MissingComponentException($"[PhysicsMover] Rigidbody не найден на объекте {gameObject.name}");
       }
   }
   ```
4. **Разграничение жизненного цикла: `Awake` против `Start` / `Initialize`**:
   - В `MonoBehaviour` запрещены C#-конструкторы (объекты создает движок через native-код).
   - В `Awake()`: только локальная самонастройка (собственные поля, `TryGetComponent` на самом себе). Запрещено обращаться к чужим компонентам на сцене — порядок вызова `Awake` между разными GameObjects недетерминирован.
   - В `Start()` или явном методе `Initialize(...)` / `Construct(...)`: межкомпонентные связи, регистрация и запуск систем.

---

## 2. Неизменяемость ScriptableObject в рантайме

1. **`ScriptableObject` — это неизменяемое определение данных (Data Definition)**:
   - Поля ScriptableObject настраиваются в инспекторе.
   - **Запрещено менять поля ScriptableObject в коде рантайма**:
     - В редакторе Unity изменение значения сохраняется на диск в `.asset` файл и затирает исходные данные.
     - В билде мутация SO не сбрасывается между перезапусками сцен и ломает состояние игры.
2. **Динамическое состояние живёт в экземпляре сущности**:
   - Конфиг задает базовые статы (`MaxHealth`, `BaseSpeed`).
   - Текущие значения (`CurrentHealth`, `CurrentSpeed`) хранятся в MonoBehaviour-компоненте, C#-модели или ECS-компоненте.

---

## 3. Изоляция Animator и декомпозиция сущности

1. **`Animator` — только пассивный визуализатор**:
   - Компонент `Animator` никогда не должен знать про логику ввода, стейт игры или статы персонажа.
   - Контроллер сущности передает параметры в аниматор (`_animator.SetFloat(SpeedHash, speed)`). Аниматор не вызывает бизнес-методы сущности напрямую.
2. **Кэширование идентификаторов Animator и Shader**:
   - Запрещено передавать строковые литералы в методы анимаций и материалов: `_animator.Play("Run")`, `_animator.SetFloat("Speed", 1f)`, `_material.SetFloat("_Cutoff", 0.5f)`. Движок хеширует строки на каждом вызове.
   - Использовать целочисленные хеши в `static readonly int` полях: `private static readonly int SpeedHash = Animator.StringToHash("Speed");` и `Shader.PropertyToID("_Cutoff")`. Запрещены строковые корутины `StartCoroutine("MoveRoutine")`.
3. **Декомпозиция движения и поведения (SRP)**:
   - Не объединять в одном скрипте перемещение, вращение, навигацию, здоровье и спавн.
   - `Mover` двигает, `Rotator` поворачивает, `NavAgent` строит путь, `Health` считает урон, `View` отображает визуальные эффекты.

---

## 4. Память, GC и контракт пулинга (Object Pooling)

1. **Контракт сброса состояния при пулинге (Pool Reset Contract)**:
   - При возврате объекта в пул и перед выдачей из пула объект обязан очистить свое состояние:
     * Сбросить физику: `rigidbody.linearVelocity = Vector3.zero; rigidbody.angularVelocity = Vector3.zero;`
     * Остановить активные корутины и твины.
     * Сбросить здоровье, кулдауны и визуальные эффекты.
2. **Никаких аллокаций в свойствах и геттерах**:
   - Запрещено вызывать `.ToArray()`, `.ToList()`, `new List<T>()` внутри свойств или методов, вызываемых каждый кадр.
   - Для чтения коллекций отдавать `IReadOnlyList<T>` по ссылке на существующий внутренний список.
3. **Кэширование `WaitForSeconds`**:
   - Не создавать `new WaitForSeconds(...)` в каждой итерации цикла. Кэшировать объект заранее либо использовать `UniTask.Delay(TimeSpan, cancellationToken: ct)`.
4. **Zero-LINQ и Zero GC Alloc в горячих путях (`Update` / `FixedUpdate`)**:
   - Запрещен LINQ (`Where`, `Select`, `OrderBy`, `FirstOrDefault`) внутри тиков и методов, вызываемых чаще одного раза в секунду. Замыкания и итераторы аллоцируют объекты в куче и вызывают GC-фризы. Использовать классические `for` циклы по индексам.
   - Запрещена строковая конкатенация и интерполяция в `Update` (`_text.text = $"Score: {_score}"` обновлять только по событию изменения счета).
5. **Безальтернативный `NonAlloc` в физических запросах**:
   - Запрещено использовать аллоцирующие запросы: `Physics.OverlapSphere`, `Physics.RaycastAll`.
   - Использовать `Physics.OverlapSphereNonAlloc` и `Physics.RaycastNonAlloc` с заранее выделенным буферным массивом `Collider[]` / `RaycastHit[]`.

---

## 5. Физика и математика

1. **Дистанции строго через `sqrMagnitude`**:
   - `Vector3.Distance` извлекает квадратный корень — это тяжелая операция. Сравнивай квадраты:
   ```csharp
   float sqrDistance = (targetPos - transform.position).sqrMagnitude;
   if (sqrDistance <= _attackRange * _attackRange) { ... }
   ```
2. **Безопасное сравнение чисел с плавающей точкой (`float`)**:
   - Запрещено прямое равенство: `if (currentHealth == 0f)` или `if (timer == maxTime)`.
   - Использовать `Mathf.Approximately(a, b)` либо `Mathf.Abs(a - b) < Mathf.Epsilon`.
3. **Физика только в `FixedUpdate`**:
   - Модификация `velocity`, вызовы `AddForce` и физические рейкасты логики выполняются строго в `FixedUpdate`.
4. **Координаты в `transform.Translate` (защита от двойного поворота)**:
   - `transform.Translate(vector)` по умолчанию считает вектор в **локальных** координатах объекта.
   - Запрещено: `transform.Translate(transform.forward * speed * Time.deltaTime)` — `transform.forward` уже является мировым вектором; при передаче в локальный `Translate` поворот применяется дважды, вызывая неконтролируемый занос.
   - Разрешено: либо локально `transform.Translate(Vector3.forward * speed * Time.deltaTime);`, либо глобально `transform.position += transform.forward * speed * Time.deltaTime;` (или с параметром `Space.World`).

---

## 6. События и отписки

1. **Стандартный C# `Action` вместо `UnityAction` / `UnityEvent` в коде**:
   - `Action<T>` работает быстрее и не создает накладных расходов сериализации Unity.
2. **Обязательная отписка**:
   - Любая подписка на событие другого объекта обязана иметь отписку в `OnDisable` или `OnDestroy`.
3. **Отложенное удаление (`Destroy` Latency)**:
   - `Destroy(gameObject)` уничтожает объект только в конце кадра. До конца кадра `obj != null` истинно, а объект остается в списках и реестрах сцены.
   - При вызове `Destroy` немедленно удалять сущность из всех внутренних списков, словарей и пространственных структур в той же строке кода.
4. **Статическое состояние и Fast Play Mode**:
   - При отключенной перезагрузке домена (Enter Play Mode Options -> Reload Domain disabled) статические события и переменные не сбрасываются между запусками игры в редакторе, сохраняя ссылки на уничтоженные объекты.
   - Статические события запрещены. При необходимости статических полей сбрасывать их через `[RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.SubsystemRegistration)]`.
