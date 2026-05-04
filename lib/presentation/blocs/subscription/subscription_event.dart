import 'package:equatable/equatable.dart';
import '../../../domain/entities/subscription.dart';

sealed class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object?> get props => [];
}

final class SubscriptionSubscriptionRequested extends SubscriptionEvent {}

final class SubscriptionAdded extends SubscriptionEvent {
  final String name;
  final double price;
  final String category;
  final DateTime nextBillingDate;

  const SubscriptionAdded({
    required this.name,
    required this.price,
    required this.category,
    required this.nextBillingDate,
  });

  @override
  List<Object?> get props => [name, price, category, nextBillingDate];
}

final class SubscriptionDeleted extends SubscriptionEvent {
  final int id;
  const SubscriptionDeleted(this.id);

  @override
  List<Object?> get props => [id];
}

final class SubscriptionUpdated extends SubscriptionEvent {
  final int id;
  final String name;
  final double price;
  final String category;
  final DateTime nextBillingDate;

  const SubscriptionUpdated({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.nextBillingDate,
  });

  @override
  List<Object?> get props => [id, name, price, category, nextBillingDate];
}

// Приватные события для связи со стримом БД
final class SubscriptionUpdatedInternal extends SubscriptionEvent {
  final List<Subscription> subscriptions;
  final double totalTotal;
  const SubscriptionUpdatedInternal(this.subscriptions, this.totalTotal);
  @override
  List<Object?> get props => [subscriptions, totalTotal];
}

final class SubscriptionErrorOccurredInternal extends SubscriptionEvent {
  final String message;
  const SubscriptionErrorOccurredInternal(this.message);
  @override
  List<Object?> get props => [message];
}

final class SubscriptionSearchQueryChanged extends SubscriptionEvent {
  final String query;
  const SubscriptionSearchQueryChanged(this.query);
  @override
  List<Object?> get props => [query];
}

final class SubscriptionCategoryFilterChanged extends SubscriptionEvent {
  final String? category;
  const SubscriptionCategoryFilterChanged(this.category);
  @override
  List<Object?> get props => [category];
}
