---
paths: ["**/*"]
---

# Управление редактором через Unity CLI

> Стандарт взаимодействия с движком Unity 6+ через официальный CLI.  
> Исключает повреждение файлов `.unity`, `.prefab`, `.asset` и гарантирует чистоту сборки.

---

## 1. Безопасность ассетов и сцен

Запрещено редактировать YAML-файлы сцен (`.unity`), префабов (`.prefab`) и ассетов (`.asset`) напрямую как текст при запущенном редакторе Unity. Прямая запись текста в эти файлы приводит к рассинхрону кэша редактора, потере GUID/FileID и повреждению ссылок.

Любые манипуляции со сценой, создание объектов, добавление компонентов, запекание NavMesh и сохранение выполняются:
1. Через **Unity CLI** (`unity command ...`) при активном редакторе.
2. Либо через C# скрипты в папке `Editor/` (`[MenuItem]` или `InitializeOnLoad`).

---

## 2. Проверка статуса редактора (Pre-flight)

Перед выполнением любых действий, связанных с запуском тестов, созданием сцен или компиляцией:

```powershell
unity status --format json
```

- Если редактор запущен и состояние `ready`: используй интерактивные команды `unity command`.
- Если редактор не запущен: пакетные команды (`unity recompile`, `unity test`) запустят headless-инстанс Unity в фоне.

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

## 4. Цикл компиляции и проверки

После изменения любого `.cs` файла агент выполняет проверку:

1. **Запустить перекомпиляцию**:
   ```powershell
   unity recompile --project-path .
   ```
2. **Проверить ошибки**:
   - Если recompile завершился с ошибкой или есть CS-номера (`CS0246`, `CS1002`) — устранить причину.
   - Проверить консоль редактора: `unity command console --level error --tail 10`.
3. **Запустить тесты (если применимо)**:
   ```powershell
   unity test . --mode EditMode --report-format junit
   ```

---

## 5. Восстановление при ошибках сборки

Если редактор Unity вошел в Safe Mode или проект не компилируется:
1. Запросить консоль: `unity command console --level error`.
2. Устранить ошибки в C# коде.
3. Если редактор перестал отвечать:
   - Проверить `Get-Process Unity`.
   - Не убивать процесс сразу, сначала попробовать `unity recompile`.
   - Если перекомпиляция разблокировала редактор — продолжить работу.
