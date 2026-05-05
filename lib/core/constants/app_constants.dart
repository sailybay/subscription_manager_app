/// Константы приложения: маршруты, ключи сессии и настройки валют.
/// Все магические строки хранятся здесь для обеспечения чистоты кода.
library;

// ─────────────────────────────────────────────────────────────────────────────
// Маршруты навигации (go_router)
// ─────────────────────────────────────────────────────────────────────────────

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String addSubscription = '/subscription/add';
  static const String analytics = '/analytics';
  static const String settings = '/settings';
  static const String categories = '/categories';
}

// ─────────────────────────────────────────────────────────────────────────────
// Drift — Настройки базы данных
// ─────────────────────────────────────────────────────────────────────────────

class DbConstants {
  DbConstants._();

  /// Имя файла базы данных
  static const String dbName = 'subscription_manager.db';
}

// ─────────────────────────────────────────────────────────────────────────────
// SharedPreferences — ключи сессии
// ─────────────────────────────────────────────────────────────────────────────

class SessionKeys {
  SessionKeys._();

  static const String isLoggedIn = 'is_logged_in';
  static const String currentUserId = 'current_user_id';
  static const String currentUserEmail = 'current_user_email';
  static const String isDarkMode = 'is_dark_mode';
}

// ─────────────────────────────────────────────────────────────────────────────
// Валюты
// ─────────────────────────────────────────────────────────────────────────────

class Currencies {
  Currencies._();

  static const String usd = 'USD';
  static const String eur = 'EUR';
  static const String rub = 'RUB';
  static const String kzt = 'KZT';

  static const List<String> all = [usd, eur, rub, kzt];

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

class AppConstants {
  AppConstants._();

  static const List<String> categories = [
    'Развлечения',
    'Музыка',
    'Видео',
    'Работа',
    'Здоровье',
    'Другое'
  ];
}
