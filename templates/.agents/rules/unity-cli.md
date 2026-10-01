---
paths: ["**/*"]
---

# Unity CLI & Live Editor Automation (True Unity CLI)

> **Стандарт взаимодействия автономных агентов с движком Unity 6+ через официальный `unity` CLI.**  
> Исключает ручное повреждение сериализованных файлов `.unity`, `.prefab`, `.asset` и гарантирует чистоту сборки.

---

## 1. Фундаментальный закон работы с Unity

> ⛔ **КАТЕГОРИЧЕСКИ ЗАПРЕЩЕНО РУКАМИ РЕДАКТИРОВАТЬ YAML-ФАЙЛЫ СЦЕН (`.unity`), ПРЕФАБОВ (`.prefab`) И АССЕТОВ (`.asset`), КОГДА ЗАПУЩЕН UNITY РЕДАКТОР.**  
> Прямая запись текста в эти файлы приводит к повреждению GUID, FileID, потере сериализованных ссылок и рассинхрону внутреннего кэша памяти редактора.

Любые манипуляции со сценой, создание объектов, добавление компонентов, запекание NavMesh и сохранение должны выполняться:
1. Через **Unity CLI** (`unity command ...`) при активном редакторе.
2. Либо через C# скрипты в папке `Editor/` (`[MenuItem]` или `InitializeOnLoad`).

---

## 2. Проверка статуса редактора (Pre-flight)

Перед выполнением любых действий, связанных с запуском тестов, созданием сцен или компиляцией:

```powershell
unity status --format json
```

- Если редактор запущен и состояние `ready` (подключен pipeline-сокет): используй интерактивные команды `unity command`.
- Если редактор не запущен: помни, что пакетные команды (`unity recompile`, `unity test`) запустят headless-инстанс Unity в фоне.

---

## 3. Живое управление сценой (`unity command`)

При подключенном редакторе используй быстрые команды для сборки уровня и настройки объектов:

### Создание и поиск объектов:
```powershell
# Создать пустой GameObject
unity command create_gameobject --name "PlayerRig"

# Создать примитив (Cube, Sphere, Capsule, Cylinder, Plane)
unity command create_primitive --type Cube --name "Ground_Blockout"

# Найти объект в иерархии
unity command find_gameobject --name "PlayerRig"
```

### Добавление и настройка компонентов:
```powershell
# Добавить компонент
unity command add_component --target "PlayerRig" --component "CharacterController"

# Вызвать запекание NavMesh
unity command bake_navmesh

# Сохранить открытую сцену
unity command save_scene
```

### Чтение логов консоли в реальном времени:
```powershell
# Последние 20 ошибок в консоли редактора
unity command console --level error --tail 20

# Все предупреждения и ошибки
unity command console --level warning --tail 30
```

---

## 4. Рабочий цикл компиляции и верификации (The Recompile Loop)

После каждого изменения любого `.cs` файла агент обязан выполнить цикл валидации:

1. **Инициировать перекомпиляцию**:
   ```powershell
   unity recompile --project-path .
   ```
2. **Проверить ошибки**:
   - Если recompile завершился с ошибкой или в выводе есть CS-номера (`CS0246`, `CS1002` и т.д.) — немедленно исправить код.
   - Проверить консоль редактора: `unity command console --level error --tail 10`.
3. **Запустить тесты (если применимо)**:
   ```powershell
   unity test . --mode EditMode --report-format junit
   ```

---

## 5. Восстановление при зависании или ошибках сборки (Safe Recovery)

Если редактор Unity вошел в Safe Mode или проект не компилируется:
1. Запроси консоль: `unity command console --level error`.
2. Устрани синтаксические и архитектурные ошибки в C#.
3. Если процесс Unity завис намертво:
   - Проверь `Get-Process Unity`.
   - Не убивай процесс без предупреждения, сначала попробуй `unity recompile`.
   - Если перекомпиляция разблокировала редактор — продолжай работу.
