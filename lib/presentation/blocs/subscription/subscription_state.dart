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
  final List<Subscription> allSubscriptions;
  final List<Subscription> filteredSubscriptions;
  final double totalMonthlySpend;
  final String searchQuery;
  final String? selectedCategory;

  const SubscriptionLoaded({
    required this.allSubscriptions,
    required this.filteredSubscriptions,
    required this.totalMonthlySpend,
    this.searchQuery = '',
    this.selectedCategory,
  });

  SubscriptionLoaded copyWith({
    List<Subscription>? allSubscriptions,
    List<Subscription>? filteredSubscriptions,
    double? totalMonthlySpend,
    String? searchQuery,
    String? selectedCategory,
    bool clearCategory = false,
  }) {
    return SubscriptionLoaded(
      allSubscriptions: allSubscriptions ?? this.allSubscriptions,
      filteredSubscriptions:
          filteredSubscriptions ?? this.filteredSubscriptions,
      totalMonthlySpend: totalMonthlySpend ?? this.totalMonthlySpend,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory:
          clearCategory ? null : (selectedCategory ?? this.selectedCategory),
    );
  }

  @override
  List<Object?> get props => [
        allSubscriptions,
        filteredSubscriptions,
        totalMonthlySpend,
        searchQuery,
        selectedCategory,
      ];
}

final class SubscriptionError extends SubscriptionState {
  final String message;
  const SubscriptionError(this.message);

  @override
  List<Object?> get props => [message];
}
