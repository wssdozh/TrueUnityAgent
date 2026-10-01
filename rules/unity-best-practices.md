---
paths: ["**/*.cs", "**/*.unity", "**/*.prefab"]
---

# Unity Best Practices & Anti-Patterns (True Unity)

> **Критический свод правил и анти-паттернов Unity для автономных ИИ-агентов.**  
> Основано на реальном опыте оптимизации, ревью кода и предотвращении утечек памяти и просадок FPS.

---

## 1. Запрет типа `GameObject` в сериализации и коде

❌ **Плохо:**
```csharp
[SerializeField] private GameObject _prefab;
[SerializeField] private GameObject _spawnPoint;
```
*Почему:* в поле типа `GameObject` можно положить абсолютно любой объект со сцены или префаб без нужного компонента. Это ломает инкапсуляцию и требует постоянных вызовов `GetComponent` в рантайме.

✅ **Правильно:**
```csharp
[SerializeField] private CharacterView _prefab;
[SerializeField] private Transform _spawnPoint;
```
*Преимущества:* строгая типизация в инспекторе Unity. Ссылка сразу типизирована нужным классом, спавн через `Instantiate(_prefab)` сразу возвращает ссылку на компонент без кастов и `GetComponent`.

---

## 2. Работа с компонентами и `TryGetComponent`

1. **Никаких слепых `GetComponent`**:
   - `GetComponent` не даёт гарантии наличия компонента на чужом объекте.
   - Используй `TryGetComponent` — он работает без аллокаций и объединяет получение ссылки и проверку:
   ```csharp
   if (collider.TryGetComponent(out Health health))
   {
       health.TakeDamage(_damage);
   }
   ```
2. **Проверка наличия компонента без сохранения**:
   - Если ссылка не нужна, а нужна только проверка:
   ```csharp
   if (collider.TryGetComponent<IInteractable>(out _))
   {
       // Подсветить маркер взаимодействия
   }
   ```
3. **Не прыгай через голову**:
   - Не запрашивай внутренние приватные компоненты у других сущностей. Инкапсулируй поведение внутри класса сущности.

---

## 3. Подписки на события: код против Инспектора

1. **Используй `Action` вместо `UnityAction` / `UnityEvent` в коде**:
   - Стандартный C# `Action` и `Action<T>` работает быстрее и не сериализуется движком вслепую.
   - Исключение: события UI элементов (`Button.onClick`).
2. **Никаких подписок на события через Инспектор**:
   - Все подписки (`button.onClick.AddListener(OnButtonClicked)`) должны быть в коде.
   - Подписки в инспекторе невозможно отследить через `Find Usages` / grep, они легко ломаются при переименовании методов.
3. **Обязательная отписка в `OnDisable` / `OnDestroy`**:
   - Любая подписка на чужое C# событие без отписки ведёт к утечке памяти (GC не может собрать объект).

---

## 4. Память, GC и Аллокации

1. **Никаких `new WaitForSeconds` в цикле**:
   ❌ **Плохо:**
   ```csharp
   while (isAlive)
   {
       yield return new WaitForSeconds(0.5f); // Создает мусор в куче каждые 0.5с!
   }
   ```
   ✅ **Правильно:** Кэшировать объект `WaitForSeconds` заранее или использовать `UniTask.Delay(TimeSpan.FromSeconds(0.5f), cancellationToken: ct)`.
2. **Расчёт расстояний через `sqrMagnitude`**:
   - Вычисление корня `Vector3.Distance` — дорогая математическая операция.
   - Для проверок радиуса всегда сравнивай квадраты расстояний:
   ```csharp
   float sqrDistance = (targetPos - transform.position).sqrMagnitude;
   if (sqrDistance <= _attackRange * _attackRange)
   {
       // В радиусе атаки
   }
   ```
3. **Пул объектов (Object Pooling) обязателен**:
   - Для всех часто создаваемых и уничтожаемых объектов (снаряды, пули, VFX взрывов, 3D-осколки, всплывающие цифры урона) использование `Destroy()` и `Instantiate()` в рантайме строго запрещено.
   - Используй `UnityEngine.Pool.ObjectPool<T>` или кастомный легковесный кольцевой пул.

---

## 5. Физика и Движение

1. **Движение только в `FixedUpdate` (для Rigidbody)**:
   - Изменение `velocity` и `AddForce` делаются только в `FixedUpdate`.
   - Чтение физических данных и рейкасты в цикле логики — в `FixedUpdate`.
2. **Не используй `transform.Translate(transform.forward * speed)`**:
   - `transform.forward` уже является вектором в мировых координатах!
   - Если передать его в `Translate` без указания `Space.World`, он умножится на локальный поворот повторно, и объект начнет «дрифтовать по диагонали».
   - Правильно: `transform.position += transform.forward * (speed * Time.deltaTime);`
3. **Рейкасты с объявлением переменной `out` на месте**:
   ```csharp
   if (Physics.Raycast(ray, out RaycastHit hit, _maxDistance, _layerMask))
   {
       // Обработка попадания
   }
   ```

---

## 6. Принцип единственной ответственности (SRP)

- Не объединяй в одном классе спавн, логику урона, визуальные эффекты и звук.
- Спавном занимается `Spawner`.
- Эффектами взрыва — `ExplosionEffect`.
- Нанесением урона — боевая логика (`DamageDealer` / ECS-система).
