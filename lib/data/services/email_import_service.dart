import 'dart:async';
import '../../../domain/entities/subscription.dart';

/// Сервис для имитации сканирования почты на предмет подписок.
class EmailImportService {
  Future<List<Subscription>> scanEmails() async {
    // Имитация процесса сканирования (задержка 4 секунды)
    await Future.delayed(const Duration(seconds: 4));

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
        name: 'Spotify',
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
        name: 'iCloud 50GB',
        price: 59,
        category: 'Другое',
        nextBillingDate: DateTime.now().add(const Duration(days: 11)),
      ),
    ];
  }
}
