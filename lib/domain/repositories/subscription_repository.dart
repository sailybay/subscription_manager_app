import '../entities/subscription.dart';

abstract class SubscriptionRepository {
  Future<List<Subscription>> getAllSubscriptions();
  Stream<List<Subscription>> watchSubscriptions();
  Future<void> addSubscription(Subscription subscription);
  Future<void> updateSubscription(Subscription subscription);
  Future<void> deleteSubscription(int id);
}
