---
paths: ["Assets/**", "Packages/**"]
---

# Project Structure & Zero Junk Policy (True File & Structure)

> **Стандарт организации структуры файлов, префабов, сцен и скриптов в Unity.**  
> Гарантирует абсолютную чистоту проекта, исключает хаос в папке `Assets` и ускоряет сборку с помощью Assembly Definitions (`asmdef`).

---

## 1. Zero Junk Policy: Правило `Assets/_Project/`

В корне папки `Assets/` **запрещено** создавать случайные скрипты, тестовые материалы или префабы!

Корень `Assets/` делится строго на:
- **`Assets/_Project/`** — **ВЕСЬ пользовательский код, ассеты, сцены и префабы проекта.** Префикс `_` держит папку на самом верху в окне Project Unity.
- **Внешние папки плагинов и пакетов** (например, `Assets/Plugins/`, `Assets/Settings/`, `Assets/TextMesh Pro/`).

---

## 2. Иерархия каталогов внутри `Assets/_Project/`

```text
Assets/_Project/
├── Develop/                     # Исходный C# код и сборки asmdef
│   ├── Runtime/                 # Код, входящий в билд игры
│   │   ├── Core/                # Точка входа, Bootstrap, сервис-локатор / DI
│   │   ├── Gameplay/            # Игровая логика (разбита по фичам)
│   │   │   ├── <FeatureName>/   # Конкретная фича (Player, Enemies, Weapons, Building)
│   │   │   │   ├── Systems/     # Системы / контроллеры логики
│   │   │   │   ├── Views/       # MonoBehaviour представления
│   │   │   │   └── Components/  # Данные, модели, ECS-компоненты
│   │   ├── UI/                  # Контроллеры интерфейса, экраны
│   │   ├── Configs/             # C# классы ScriptableObject
│   │   └── Common/              # Общие утилиты, математика, пулинг
│   └── Editor/                  # Редакторские скрипты, тулзы, кастомные инспекторы
├── Scenes/                      # Файлы сцен Unity (.unity)
│   ├── _Core/                   # Инициализирующие сцены (Boot, Init)
│   ├── Gameplay/                # Основные игровые уровни
│   └── Sandboxes/               # Тестовые полигоны разработчиков
├── Prefabs/                     # Префабы (.prefab), сгруппированные по категориям
│   ├── Player/
│   ├── Enemies/
│   ├── Environment/
│   ├── VFX/
│   └── UI/
├── Art/                         # Визуальные исходники и ассеты
│   ├── Materials/               # Материалы (.mat)
│   ├── Shaders/                 # Шейдеры (.shader, .shadergraph)
│   ├── Models/                  # 3D модели (.fbx, .obj)
│   └── Textures/                # Текстуры (.png, .tga)
├── Audio/                       # Звуки и музыка
│   ├── SFX/
│   ├── Music/
│   └── Mixers/
├── Configs/                     # Экземпляры ScriptableObject (.asset)
└── UI/                          # UI спрайты, шрифты
```

---

## 3. Соглашения по именованию файлов и ассетов

| Тип ресурса | Префикс / Суффикс | Шаблон имени | Пример |
| :--- | :--- | :--- | :--- |
| **C# Скрипт логики** | Без префикса | `PascalCase.cs` | `PlayerMover.cs` |
| **C# Скрипт View** | Суффикс `View` | `PascalCaseView.cs` | `HealthBarView.cs` |
| **C# ScriptableObject** | Суффикс `Config` | `PascalCaseConfig.cs` | `EnemyStatsConfig.cs` |
| **Экземпляр SO (.asset)** | Категория / Имя | `PascalCase.asset` | `RuskerFastStats.asset` |
| **Материал URP** | Префикс `M_` | `M_<Category>_<Name>.mat` | `M_Floor_Blockout.mat` |
| **Шейдер** | Префикс `SH_` | `SH_<Name>` | `SH_Dissolve.shadergraph` |
| **Текстура** | Префикс `T_` | `T_<Name>_<Channel>.png` | `T_Cookie_BaseColor.png` |
| **Сцена** | Префикс типа | `<Type>_<Name>.unity` | `Gameplay_Arena.unity` |
| **Звуковой эффект** | Префикс `sfx_` | `sfx_<event>.wav` | `sfx_sword_hit.wav` |
| **Музыкальный трек** | Префикс `mus_` | `mus_<theme>.mp3` | `mus_combat_wave1.mp3` |

---

## 4. Сборка через Assembly Definitions (`asmdef`)

Чтобы код компилировался за миллисекунды, а не минуты:
1. В `Assets/_Project/Develop/Runtime/` размещается `_Project.Runtime.asmdef`.
2. В `Assets/_Project/Develop/Editor/` размещается `_Project.Editor.asmdef` с платформой strictly `Editor` и ссылкой на `_Project.Runtime`.
3. Сторонние библиотеки подключаются ссылками в asmdef, а не компилируются в единую общую кашу `Assembly-CSharp.dll`.
