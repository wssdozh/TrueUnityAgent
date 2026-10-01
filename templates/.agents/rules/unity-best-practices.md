---
paths: ["**/*.cs", "**/*.unity", "**/*.prefab"]
---

# Unity Best Practices & Architecture Traps (True Unity)

> Свод правил и ловушек движка Unity для предотвращения утечек памяти, рассинхрона префабов и просадок производительности.

---

## 1. Сериализация и зависимости компонентов

1. **Запрет типа `GameObject` в сериализации**:
   - `[SerializeField] private CharacterView _prefab;` вместо `[SerializeField] private GameObject _prefab;`.
   - Поле обязано быть строго типизировано целевым компонентом или `Transform`. Это исключает подсовывание невалидных префабов и убирает лишние `GetComponent` при спавне.
2. **Безальтернативный `TryGetComponent`**:
   - Никогда не использовать слепой `GetComponent` на сторонних объектах. `TryGetComponent` не аллоцирует память в куче и сразу проверяет наличие:
   ```csharp
   if (collider.TryGetComponent(out IDamageable target))
   {
       target.TakeDamage(_damage);
   }
   ```
3. **Запрет тихих `return` при отсутствии обязательных зависимостей**:
   - ⛔ **Антипаттерн**: `if (_rigidbody == null) return;` внутри `Update()` / `FixedUpdate()`. Это маскирует ошибки настройки префабов на сцене.
   - ✅ **Правильно**: Валидировать ссылки в `Awake()` с явным выбросом исключения или логом ошибки:
   ```csharp
   private void Awake()
   {
       if (TryGetComponent(out _rigidbody) == false)
       {
           throw new MissingComponentException($"[PhysicsMover] Rigidbody не найден на объекте {gameObject.name}");
       }
   }
   ```

---

## 2. Неизменяемость ScriptableObject (Immutable Configs)

1. **`ScriptableObject` — это неизменяемое определение данных (Data Definition)**:
   - Поля ScriptableObject настраиваются геймдизайнером в инспекторе.
   - **Запрещено изменять поля ScriptableObject в коде рантайма**:
     - В редакторе Unity изменение значения поля SO сохраняется на диск в `.asset` файл и затирает исходные данные.
     - В собранном билде мутация SO не сбрасывается между перезапусками сцен и ломает состояние игры.
2. **Динамическое состояние живёт в экземпляре сущности**:
   - Конфиг задает базовые статы (`MaxHealth`, `BaseSpeed`).
   - Текущие значения (`CurrentHealth`, `CurrentSpeed`) хранятся в MonoBehaviour-компоненте, C#-модели или ECS-компоненте.

---

## 3. Изоляция Animator и декомпозиция сущности

1. **`Animator` — только пассивный визуализатор**:
   - Компонент `Animator` никогда не должен знать про логику ввода, стейт игры или статы персонажа.
   - Контроллер сущности передает параметры в аниматор (`_animator.SetFloat(SpeedHash, speed)`). Аниматор не вызывает бизнес-методы сущности напрямую.
2. **Декомпозиция движения и поведения (SRP)**:
   - Не объединять в одном скрипте перемещение, вращение, навигацию, здоровье и спавн.
   - `Mover` двигает, `Rotator` поворачивает, `NavAgent` строит путь, `Health` считает урон, `View` отображает визуальные эффекты.

---

## 4. Память, GC и контракт пулинга (Object Pooling)

1. **Обязательный сброс состояния при пулинге (Pool Reset Contract)**:
   - При возврате объекта в пул и перед выдачей из пула объект обязан очистить свое состояние:
     * Сбросить физику: `rigidbody.linearVelocity = Vector3.zero; rigidbody.angularVelocity = Vector3.zero;`
     * Остановить активные корутины и твины (`KillTweens()`).
     * Сбросить здоровье, кулдауны и визуальные эффекты.
2. **Никаких аллокаций в свойствах и геттерах**:
   - Запрещено вызывать `.ToArray()`, `.ToList()`, `new List<T>()` внутри свойств или методов, вызываемых каждый кадр.
   - Для чтения коллекций отдавать `IReadOnlyList<T>` по ссылке на существующий внутренний список.
3. **Кэширование `WaitForSeconds`**:
   - Не создавать `new WaitForSeconds(...)` в каждой итерации цикла. Кэшировать объект заранее либо использовать `UniTask.Delay(TimeSpan, cancellationToken: ct)`.

---

## 5. Физика и математика

1. **Дистанции строго через `sqrMagnitude`**:
   - `Vector3.Distance` извлекает квадратный корень — это тяжелая операция. Сравнивай квадраты:
   ```csharp
   float sqrDistance = (targetPos - transform.position).sqrMagnitude;
   if (sqrDistance <= _attackRange * _attackRange) { ... }
   ```
2. **Безопасное сравнение чисел с плавающей точкой (`float`)**:
   - Запрещено: `if (currentHealth == 0f)` или `if (timer == maxTime)`.
   - Использовать `Mathf.Approximately(a, b)` либо `Mathf.Abs(a - b) < Mathf.Epsilon`.
3. **Физика только в `FixedUpdate`**:
   - Модификация `velocity`, вызовы `AddForce` и физические рейкасты логики выполняются строго в `FixedUpdate`.

---

## 6. События и отписки

1. **Стандартный C# `Action` вместо `UnityAction` / `UnityEvent` в коде**:
   - `Action<T>` работает в разы быстрее и не создает накладных расходов сериализации Unity.
2. **Обязательная отписка**:
   - Любая подписка на событие другого объекта обязана иметь отписку в `OnDisable` или `OnDestroy`.
