/// Константы приложения: маршруты, имена Hive-боксов, ключи сессии и валюты.
/// Все магические строки хранятся здесь — не разбросаны по коду.
library;

// ─────────────────────────────────────────────────────────────────────────────
// Маршруты навигации (go_router)
// ─────────────────────────────────────────────────────────────────────────────

/// Пути маршрутов приложения.
/// Используются в go_router и при навигации через context.go() / context.push().
class AppRoutes {
  AppRoutes._(); // Приватный конструктор — класс не инстанцируется

  /// Корневой маршрут — перенаправляет на /home или /login
  static const String splash = '/';

  /// Экран входа в аккаунт
  static const String login = '/login';

  /// Экран регистрации нового пользователя
  static const String register = '/register';

  /// Главный экран (список подписок)
  static const String home = '/home';

  /// Экран добавления новой подписки
  static const String addSubscription = '/subscription/add';

  /// Экран редактирования подписки (:id — path-параметр)
  static const String editSubscription = '/subscription/edit/:id';

  /// Экран аналитики расходов
  static const String analytics = '/analytics';

  /// Экран управления категориями
  static const String categories = '/categories';
}

// ─────────────────────────────────────────────────────────────────────────────
// Hive — имена боксов (локальная база данных)
// ─────────────────────────────────────────────────────────────────────────────

/// Имена Hive-боксов для хранения данных.
/// Каждый бокс открывается в main.dart перед запуском приложения.
class HiveBoxNames {
  HiveBoxNames._();

  /// Бокс подписок пользователей
  static const String subscriptions = 'subscriptions';

  /// Бокс категорий
  static const String categories = 'categories';

  /// Бокс пользователей (для локальной аутентификации)
  static const String users = 'users';
}

// ─────────────────────────────────────────────────────────────────────────────
// Hive — идентификаторы TypeAdapter (должны быть уникальными в проекте!)
// ─────────────────────────────────────────────────────────────────────────────

/// Уникальные int-идентификаторы для Hive TypeAdapter.
/// Генерируются через build_runner по аннотациям @HiveType(typeId: ...).
/// ВАЖНО: не изменять существующие значения — это сломает сохранённые данные!
class HiveTypeIds {
  HiveTypeIds._();

  /// TypeId для SubscriptionModel
  static const int subscription = 0;

  /// TypeId для CategoryModel
  static const int category = 1;

  /// TypeId для UserModel
  static const int user = 2;
}

// ─────────────────────────────────────────────────────────────────────────────
// SharedPreferences — ключи для хранения сессии
// ─────────────────────────────────────────────────────────────────────────────

/// Ключи SharedPreferences для хранения данных текущей сессии.
/// SharedPreferences используется для лёгких данных (флаги, строки).
class SessionKeys {
  SessionKeys._();

  /// Флаг: пользователь авторизован?
  static const String isLoggedIn = 'is_logged_in';

  /// UUID текущего пользователя
  static const String currentUserId = 'current_user_id';

  /// Email текущего пользователя (для отображения)
  static const String currentUserEmail = 'current_user_email';
}

// ─────────────────────────────────────────────────────────────────────────────
// Валюты
// ─────────────────────────────────────────────────────────────────────────────

/// Поддерживаемые валюты.
/// Расширяется при необходимости — просто добавить новую константу и в [all].
class Currencies {
  Currencies._();

  static const String usd = 'USD'; // Доллар США
  static const String eur = 'EUR'; // Евро
  static const String rub = 'RUB'; // Российский рубль
  static const String kzt = 'KZT'; // Казахстанский тенге

  /// Полный список валют для dropdown-меню
  static const List<String> all = [usd, eur, rub, kzt];

  /// Возвращает символ валюты по ISO-коду
  static String symbol(String code) {
    const map = {
      usd: '\$',
      eur: '€',
      rub: '₽',
      kzt: '₸',
    };
    return map[code] ?? code;
  }
}
