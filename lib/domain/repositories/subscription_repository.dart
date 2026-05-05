import '../entities/subscription.dart';

abstract class SubscriptionRepository {
  Future<List<Subscription>> getAllSubscriptions();
  Stream<List<Subscription>> watchSubscriptions();

  /// Добавляет подписку и возвращает её ID в базе данных
  Future<int> addSubscription(Subscription subscription);

  Future<void> updateSubscription(Subscription subscription);
  Future<void> deleteSubscription(int id);
}
