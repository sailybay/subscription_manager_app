import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/subscription.dart';
import '../../../domain/repositories/subscription_repository.dart';
import 'subscription_event.dart';
import 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final SubscriptionRepository _repository;
  StreamSubscription? _subscriptionStream;

  SubscriptionBloc(this._repository) : super(SubscriptionInitial()) {
    on<SubscriptionSubscriptionRequested>(_onSubscriptionRequested);
    on<SubscriptionAdded>(_onSubscriptionAdded);
    on<SubscriptionUpdated>(_onSubscriptionUpdated);
    on<SubscriptionDeleted>(_onSubscriptionDeleted);
    on<SubscriptionUpdatedInternal>(_onSubscriptionUpdatedInternal);
    on<SubscriptionErrorOccurredInternal>(_onSubscriptionErrorOccurred);
    on<SubscriptionSearchQueryChanged>(_onSearchQueryChanged);
    on<SubscriptionCategoryFilterChanged>(_onCategoryFilterChanged);
  }

  Future<void> _onSubscriptionRequested(
    SubscriptionSubscriptionRequested event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());
    await _subscriptionStream?.cancel();
    _subscriptionStream = _repository.watchSubscriptions().listen(
      (subscriptions) {
        final total =
            subscriptions.fold<double>(0, (sum, item) => sum + item.price);
        add(SubscriptionUpdatedInternal(subscriptions, total));
      },
      onError: (e) => add(
          const SubscriptionErrorOccurredInternal('Ошибка загрузки данных')),
    );
  }

  void _onSubscriptionUpdatedInternal(
    SubscriptionUpdatedInternal event,
    Emitter<SubscriptionState> emit,
  ) {
    String currentQuery = '';
    String? currentCategory;

    if (state is SubscriptionLoaded) {
      currentQuery = (state as SubscriptionLoaded).searchQuery;
      currentCategory = (state as SubscriptionLoaded).selectedCategory;
    }

    final filtered =
        _applyFilters(event.subscriptions, currentQuery, currentCategory);

    emit(SubscriptionLoaded(
      allSubscriptions: event.subscriptions,
      filteredSubscriptions: filtered,
      totalMonthlySpend: event.totalTotal,
      searchQuery: currentQuery,
      selectedCategory: currentCategory,
    ));
  }

  void _onSearchQueryChanged(
    SubscriptionSearchQueryChanged event,
    Emitter<SubscriptionState> emit,
  ) {
    if (state is SubscriptionLoaded) {
      final s = state as SubscriptionLoaded;
      final filtered =
          _applyFilters(s.allSubscriptions, event.query, s.selectedCategory);
      emit(s.copyWith(
          searchQuery: event.query, filteredSubscriptions: filtered));
    }
  }

  void _onCategoryFilterChanged(
    SubscriptionCategoryFilterChanged event,
    Emitter<SubscriptionState> emit,
  ) {
    if (state is SubscriptionLoaded) {
      final s = state as SubscriptionLoaded;
      final filtered =
          _applyFilters(s.allSubscriptions, s.searchQuery, event.category);
      emit(s.copyWith(
        selectedCategory: event.category,
        clearCategory: event.category == null,
        filteredSubscriptions: filtered,
      ));
    }
  }

  List<Subscription> _applyFilters(
      List<Subscription> subs, String query, String? category) {
    return subs.where((s) {
      final matchesQuery = s.name.toLowerCase().contains(query.toLowerCase());
      final matchesCategory = category == null || s.category == category;
      return matchesQuery && matchesCategory;
    }).toList();
  }

  void _onSubscriptionErrorOccurred(
    SubscriptionErrorOccurredInternal event,
    Emitter<SubscriptionState> emit,
  ) {
    emit(SubscriptionError(event.message));
  }

  Future<void> _onSubscriptionAdded(
    SubscriptionAdded event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      final newSub = Subscription(
          id: 0,
          name: event.name,
          price: event.price,
          category: event.category,
          nextBillingDate: event.nextBillingDate);
      await _repository.addSubscription(newSub);
    } catch (e) {
      add(const SubscriptionErrorOccurredInternal('Ошибка при добавлении'));
    }
  }

  Future<void> _onSubscriptionUpdated(
    SubscriptionUpdated event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      final updatedSub = Subscription(
          id: event.id,
          name: event.name,
          price: event.price,
          category: event.category,
          nextBillingDate: event.nextBillingDate);
      await _repository.updateSubscription(updatedSub);
    } catch (e) {
      add(const SubscriptionErrorOccurredInternal('Ошибка при обновлении'));
    }
  }

  Future<void> _onSubscriptionDeleted(
    SubscriptionDeleted event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      await _repository.deleteSubscription(event.id);
    } catch (e) {
      add(const SubscriptionErrorOccurredInternal('Ошибка при удалении'));
    }
  }

  @override
  Future<void> close() {
    _subscriptionStream?.cancel();
    return super.close();
  }
}
