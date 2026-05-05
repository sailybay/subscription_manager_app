import 'package:drift/drift.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../database/app_database.dart' as db;

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final db.AppDatabase _db;

  SubscriptionRepositoryImpl(this._db);

  @override
  Future<List<Subscription>> getAllSubscriptions() async {
    final results = await _db.select(_db.subscriptions).get();
    return results.map(_mapToEntity).toList();
  }

  @override
  Stream<List<Subscription>> watchSubscriptions() {
    return _db.select(_db.subscriptions).watch().map(
          (rows) => rows.map(_mapToEntity).toList(),
        );
  }

  @override
  Future<int> addSubscription(Subscription subscription) async {
    return await _db.into(_db.subscriptions).insert(
          db.SubscriptionsCompanion.insert(
            name: subscription.name,
            price: subscription.price,
            category: subscription.category,
            nextBillingDate: subscription.nextBillingDate,
          ),
        );
  }

  @override
  Future<void> updateSubscription(Subscription subscription) async {
    await (_db.update(_db.subscriptions)
          ..where((t) => t.id.equals(subscription.id)))
        .write(
      db.SubscriptionsCompanion(
        name: Value(subscription.name),
        price: Value(subscription.price),
        category: Value(subscription.category),
        nextBillingDate: Value(subscription.nextBillingDate),
      ),
    );
  }

  @override
  Future<void> deleteSubscription(int id) async {
    await (_db.delete(_db.subscriptions)..where((t) => t.id.equals(id))).go();
  }

  // Конвертер из Drift Row в Domain Entity
  Subscription _mapToEntity(db.SubscriptionTableData data) {
    return Subscription(
      id: data.id,
      name: data.name,
      price: data.price,
      category: data.category,
      nextBillingDate: data.nextBillingDate,
    );
  }
}
