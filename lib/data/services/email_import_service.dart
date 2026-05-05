import 'dart:async';
import '../../../domain/entities/subscription.dart';

/// Сервис для имитации сканирования почты на предмет подписок.
class EmailImportService {
  Future<List<Subscription>> scanEmails() async {
    // Имитация более сложного "умного" сканирования
    // Мы делим задержку на части, чтобы UI мог показывать прогресс (опционально)
    await Future.delayed(const Duration(seconds: 4));

    // Расширенный список мок-данных для реалистичности
    return [
      Subscription(
        id: 101,
        name: 'Netflix',
        price: 990,
        category: 'Видео',
        nextBillingDate: DateTime.now().add(const Duration(days: 14)),
      ),
      Subscription(
        id: 102,
        name: 'Spotify Premium',
        price: 169,
        category: 'Музыка',
        nextBillingDate: DateTime.now().add(const Duration(days: 6)),
      ),
      Subscription(
        id: 103,
        name: 'YouTube Premium',
        price: 249,
        category: 'Видео',
        nextBillingDate: DateTime.now().add(const Duration(days: 21)),
      ),
      Subscription(
        id: 104,
        name: 'Яндекс Плюс',
        price: 299,
        category: 'Развлечения',
        nextBillingDate: DateTime.now().add(const Duration(days: 3)),
      ),
      Subscription(
        id: 105,
        name: 'ChatGPT Plus',
        price: 1850,
        category: 'Работа',
        nextBillingDate: DateTime.now().add(const Duration(days: 10)),
      ),
      Subscription(
        id: 106,
        name: 'IVI',
        price: 399,
        category: 'Видео',
        nextBillingDate: DateTime.now().add(const Duration(days: 18)),
      ),
      Subscription(
        id: 107,
        name: 'iCloud 50GB',
        price: 59,
        category: 'Другое',
        nextBillingDate: DateTime.now().add(const Duration(days: 11)),
      ),
    ];
  }
}
