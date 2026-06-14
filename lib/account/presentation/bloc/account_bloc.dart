import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/queries/get_active_subscription_query.dart';
import '../../domain/entities/subscription.dart';

// --- Events ---

abstract class AccountEvent {}

class LoadActiveSubscriptionEvent extends AccountEvent {
  final int userId;
  LoadActiveSubscriptionEvent(this.userId);
}

// --- States ---

abstract class AccountState {}

class AccountInitial extends AccountState {}

class AccountLoading extends AccountState {}

class AccountSubscriptionLoaded extends AccountState {
  final Subscription subscription;
  AccountSubscriptionLoaded(this.subscription);
}

class AccountError extends AccountState {
  final String message;
  AccountError(this.message);
}

// --- BLoC ---

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final GetActiveSubscriptionQuery _query;

  AccountBloc(this._query) : super(AccountInitial()) {
    on<LoadActiveSubscriptionEvent>(_onLoadSubscription);
  }

  Future<void> _onLoadSubscription(
    LoadActiveSubscriptionEvent event,
    Emitter<AccountState> emit,
  ) async {
    emit(AccountLoading());
    final result = await _query.execute(event.userId);
    result.fold(
      (failure) => emit(AccountError(failure.message)),
      (subscription) => emit(AccountSubscriptionLoaded(subscription)),
    );
  }
}
