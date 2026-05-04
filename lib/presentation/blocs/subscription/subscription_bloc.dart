import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/subscription.dart';
import '../../../domain/repositories/subscription_repository.dart';
import '../../../core/services/notification_service.dart';
import 'subscription_event.dart';
import 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final SubscriptionRepository _repository;
  final NotificationService _notificationService;
  StreamSubscription? _subscriptionStream;

  SubscriptionBloc(this._repository, this._notificationService)
      : super(SubscriptionInitial()) {
    on<SubscriptionSubscriptionRequested>(_onSubscriptionRequested);
    on<SubscriptionAdded>(_onSubscriptionAdded);
    on<SubscriptionUpdated>(_onSubscriptionUpdated);
    on<SubscriptionDeleted>(_onSubscriptionDeleted);
    on<SubscriptionUpdatedInternal>(_onSubscriptionUpdatedInternal);
    on<SubscriptionErrorOccurredInternal>(_onSubscriptionErrorOccurred);
    on<SubscriptionSearchQueryChanged>(_onSearchQueryChanged);
    on<SubscriptionCategoryFilterChanged>(_onCategoryFilterChanged);
  }

  Future<void> _onSubscriptionRequested(SubscriptionSubscriptionRequested event,
      Emitter<SubscriptionState> emit) async {
    emit(SubscriptionLoading());
    await _subscriptionStream?.cancel();
    _subscriptionStream = _repository.watchSubscriptions().listen(
      (subs) {
        final total = subs.fold<double>(0, (sum, item) => sum + item.price);
        add(SubscriptionUpdatedInternal(subs, total));
      },
      onError: (e) => add(
          const SubscriptionErrorOccurredInternal('Ошибка загрузки данных')),
    );
  }

  void _onSubscriptionUpdatedInternal(
      SubscriptionUpdatedInternal event, Emitter<SubscriptionState> emit) {
    String query = '';
    String? category;
    final currentState = state;
    if (currentState is SubscriptionLoaded) {
      query = currentState.searchQuery;
      category = currentState.selectedCategory;
    }
    final filtered = _applyFilters(event.subscriptions, query, category);
    emit(SubscriptionLoaded(
      allSubscriptions: event.subscriptions,
      filteredSubscriptions: filtered,
      totalMonthlySpend: event.totalTotal,
      searchQuery: query,
      selectedCategory: category,
    ));
  }

  void _onSearchQueryChanged(
      SubscriptionSearchQueryChanged event, Emitter<SubscriptionState> emit) {
    final s = state;
    if (s is SubscriptionLoaded) {
      final filtered =
          _applyFilters(s.allSubscriptions, event.query, s.selectedCategory);
      emit(s.copyWith(
          searchQuery: event.query, filteredSubscriptions: filtered));
    }
  }

  void _onCategoryFilterChanged(SubscriptionCategoryFilterChanged event,
      Emitter<SubscriptionState> emit) {
    final s = state;
    if (s is SubscriptionLoaded) {
      final filtered =
          _applyFilters(s.allSubscriptions, s.searchQuery, event.category);
      emit(s.copyWith(
          selectedCategory: event.category,
          clearCategory: event.category == null,
          filteredSubscriptions: filtered));
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

  void _onSubscriptionErrorOccurred(SubscriptionErrorOccurredInternal event,
          Emitter<SubscriptionState> emit) =>
      emit(SubscriptionError(event.message));

  Future<void> _onSubscriptionAdded(
      SubscriptionAdded event, Emitter<SubscriptionState> emit) async {
    try {
      final newSub = Subscription(
          id: 0,
          name: event.name,
          price: event.price,
          category: event.category,
          nextBillingDate: event.nextBillingDate);
      await _repository.addSubscription(newSub);
      // Примечание: Уведомление лучше планировать после того, как БД присвоит ID,
      // но для MVP мы можем перепланировать все уведомления при получении нового списка из базы или использовать данные события.
    } catch (_) {
      add(const SubscriptionErrorOccurredInternal('Ошибка при добавлении'));
    }
  }

  Future<void> _onSubscriptionUpdated(
      SubscriptionUpdated event, Emitter<SubscriptionState> emit) async {
    try {
      final sub = Subscription(
          id: event.id,
          name: event.name,
          price: event.price,
          category: event.category,
          nextBillingDate: event.nextBillingDate);
      await _repository.updateSubscription(sub);
      await _notificationService.scheduleSubscriptionReminder(sub);
    } catch (_) {
      add(const SubscriptionErrorOccurredInternal('Ошибка при обновлении'));
    }
  }

  Future<void> _onSubscriptionDeleted(
      SubscriptionDeleted event, Emitter<SubscriptionState> emit) async {
    try {
      await _repository.deleteSubscription(event.id);
      await _notificationService.cancelReminder(event.id);
    } catch (_) {
      add(const SubscriptionErrorOccurredInternal('Ошибка при удалении'));
    }
  }

  @override
  Future<void> close() {
    _subscriptionStream?.cancel();
    return super.close();
  }
}
