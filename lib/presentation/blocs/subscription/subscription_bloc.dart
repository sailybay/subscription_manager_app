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
    on<SubscriptionDeleted>(_onSubscriptionDeleted);
    on<SubscriptionUpdatedInternal>(_onSubscriptionUpdated);
    on<SubscriptionErrorOccurredInternal>(_onSubscriptionErrorOccurred);
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

  void _onSubscriptionUpdated(
    SubscriptionUpdatedInternal event,
    Emitter<SubscriptionState> emit,
  ) {
    emit(SubscriptionLoaded(
      subscriptions: event.subscriptions,
      totalMonthlySpend: event.totalTotal,
    ));
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
        nextBillingDate: event.nextBillingDate,
      );
      await _repository.addSubscription(newSub);
    } catch (e) {
      add(const SubscriptionErrorOccurredInternal('Ошибка при добавлении'));
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
