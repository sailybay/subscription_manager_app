# 📱 SubManager — Менеджер подписок

> Приложение для умного управления цифровыми подписками. Отслеживай расходы, анализируй категории и никогда не забывай о дате следующего платежа.

---

## 📸 Скриншоты
<p align="center">
<img width="1280" height="2856" alt="Screenshot_1778091105" src="https://github.com/user-attachments/assets/b3d8060f-39c9-43b3-91b4-5bf0ad34ccdb" />
<img width="1280" height="2856" alt="Screenshot_1778091096" src="https://github.com/user-attachments/assets/b1de66f7-ff80-4b3f-86b1-9a2be852e4b8" />
<img width="1280" height="2856" alt="Screenshot_1778091108" src="https://github.com/user-attachments/assets/75317f21-b6ce-4a59-9b78-bc9d1a585add" />
<img width="1280" height="2856" alt="Screenshot_1778091115" src="https://github.com/user-attachments/assets/b6dda6d4-b7c9-443b-b788-0cbb0a58ccdb" />
<img width="1280" height="2856" alt="Screenshot_1778091126" src="https://github.com/user-attachments/assets/e4377979-bd5f-46a8-9f39-5a53f8465489" />
<img width="1280" height="2856" alt="Screenshot_1778091933" src="https://github.com/user-attachments/assets/1802322f-2194-41af-93ba-d11bb770e626" />
</p>
|

---

## ✨ Возможности

- 🔐 **Аутентификация** — регистрация и вход с валидацией данных, сессия сохраняется между запусками
- 📋 **Управление подписками** — добавление, редактирование и удаление с выбором категории и даты платежа
- 🔍 **Умный поиск и фильтры** — поиск по названию и фильтрация по категориям в реальном времени
- 📊 **Аналитика** — круговая диаграмма расходов по категориям, суммарные траты за месяц
- 🤖 **Умный импорт из почты** — автоматическое сканирование и предложение подписок (без дублей)
- 📤 **Экспорт в CSV** — выгрузка списка подписок с возможностью поделиться файлом
- 🔔 **Уведомления** — напоминания перед датой платежа
- 🌗 **Темная и светлая темы** — переключение в Настройках

---

## 🏗 Архитектура

Проект построен по принципам **Clean Architecture** с разделением на три слоя:

```
lib/
├── core/               # Константы, тема, DI, утилиты, роутер
├── data/               # Реализации репозиториев, БД (Drift), сервисы
├── domain/             # Сущности (Entities) и интерфейсы репозиториев
└── presentation/       # Экраны, BLoC-блоки, виджеты
```

**Стек технологий:**

| Слой | Библиотека |
|------|----------|
| Состояние (State Management) | `flutter_bloc` |
| Навигация | `go_router` |
| База данных | `drift` (SQLite) |
| Dependency Injection | `get_it` |
| Графики | `fl_chart` |
| Уведомления | `flutter_local_notifications` |
| Шаринг файлов | `share_plus` |
| Хранение сессии | `shared_preferences` |

---

## 🚀 Инструкция по запуску

### Требования

- Flutter SDK `>=3.4.4`
- Dart SDK `>=3.4.4`
- Android Studio / VS Code с плагином Flutter
- Подключенный Android-эмулятор или физическое устройство

### Шаги

**1. Клонируйте репозиторий**
```bash
git clone https://github.com/sailybayE/subscription_manager_app.git
cd subscription_manager_app
```

**2. Установите зависимости**
```bash
flutter pub get
```

**3. Сгенерируйте код базы данных (Drift)**
```bash
dart run build_runner build --delete-conflicting-outputs
```

**4. Запустите приложение**
```bash
flutter run
```

> ⚠️ После первого добавления новых пакетов (`share_plus` и т.д.) обязательно выполните **полный перезапуск** приложения (Stop → Run), а не Hot Reload.

### Сборка Release APK

```bash
flutter build apk --release
```

Готовый файл будет находиться по пути:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## 📁 Структура проекта

```
lib/
├── core/
│   ├── constants/      # AppConstants, AppRoutes
│   ├── di/             # service_locator.dart (get_it)
│   ├── extensions/     # context_extensions.dart
│   ├── router/         # app_router.dart (go_router)
│   ├── services/       # notification_service.dart
│   ├── theme/          # app_theme.dart
│   └── utils/          # app_utils.dart (форматирование, CSV)
├── data/
│   ├── database/       # app_database.dart (Drift)
│   ├── repositories/   # auth_repository_impl, subscription_repository_impl
│   └── services/       # email_import_service.dart
├── domain/
│   ├── entities/       # subscription.dart, user_entity.dart
│   └── repositories/   # интерфейсы репозиториев
└── presentation/
    ├── blocs/          # auth_bloc, subscription_bloc, theme_bloc
    ├── screens/        # auth, home, analytics, settings, subscription
    └── widgets/        # переиспользуемые ui-компоненты
```

---

## 👤 Автор

Bakdaulet Sailybay<img width="1280" height="2856" alt="Screenshot_1778091096" src="https://github.com/user-attachments/assets/8e094bfa-6372-4a94-a150-86f4c7fe4057" />

- GitHub: [@sailybay](https://github.com/sailybay)

---

## 📄 Лицензия

Этот проект создан в учебных целях как финальная работа по курсу Flutter-разработки.
