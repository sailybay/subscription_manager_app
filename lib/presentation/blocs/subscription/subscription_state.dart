import 'package:equatable/equatable.dart';
import '../../../domain/entities/subscription.dart';

sealed class SubscriptionState extends Equatable {
  const SubscriptionState();

  @override
  List<Object?> get props => [];
}

final class SubscriptionInitial extends SubscriptionState {}

final class SubscriptionLoading extends SubscriptionState {}

final class SubscriptionLoaded extends SubscriptionState {
  final List<Subscription> subscriptions;
  final double totalMonthlySpend;

  const SubscriptionLoaded({
    required this.subscriptions,
    required this.totalMonthlySpend,
  });

  @override
  List<Object?> get props => [subscriptions, totalMonthlySpend];
}

final class SubscriptionError extends SubscriptionState {
  final String message;
  const SubscriptionError(this.message);

  @override
  List<Object?> get props => [message];
}
