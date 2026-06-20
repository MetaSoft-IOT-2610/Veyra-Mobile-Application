import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/commands/create_subscription_command.dart';
import '../../application/queries/get_active_subscription_query.dart';
import '../../domain/entities/subscription.dart';

// --- Events ---

abstract class AccountEvent {}

class LoadActiveSubscriptionEvent extends AccountEvent {
  final int userId;
  LoadActiveSubscriptionEvent(this.userId);
}

class CreateSubscriptionEvent extends AccountEvent {
  final int userId;
  final String planType;
  final String period;

  CreateSubscriptionEvent({
    required this.userId,
    required this.planType,
    required this.period,
  });
}

// --- States ---

abstract class AccountState {}

class AccountInitial extends AccountState {}

class AccountLoading extends AccountState {}

class AccountSubscriptionLoaded extends AccountState {
  final Subscription subscription;
  AccountSubscriptionLoaded(this.subscription);
}

class AccountNoSubscription extends AccountState {}

class AccountSubscriptionCreated extends AccountState {
  final Subscription subscription;
  AccountSubscriptionCreated(this.subscription);
}

class AccountError extends AccountState {
  final String message;
  AccountError(this.message);
}

// --- BLoC ---

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final GetActiveSubscriptionQuery _query;
  final CreateSubscriptionCommand _createSubscriptionCommand;

  AccountBloc(this._query, this._createSubscriptionCommand)
    : super(AccountInitial()) {
    on<LoadActiveSubscriptionEvent>(_onLoadSubscription);
    on<CreateSubscriptionEvent>(_onCreateSubscription);
  }

  Future<void> _onLoadSubscription(
    LoadActiveSubscriptionEvent event,
    Emitter<AccountState> emit,
  ) async {
    emit(AccountLoading());
    final result = await _query.execute(event.userId);
    result.fold((failure) {
      if (failure.code == '404') {
        emit(AccountNoSubscription());
        return;
      }

      emit(AccountError(failure.message));
    }, (subscription) => emit(AccountSubscriptionLoaded(subscription)));
  }

  Future<void> _onCreateSubscription(
    CreateSubscriptionEvent event,
    Emitter<AccountState> emit,
  ) async {
    emit(AccountLoading());
    final result = await _createSubscriptionCommand.execute(
      userId: event.userId,
      planType: event.planType,
      period: event.period,
    );

    result.fold(
      (failure) => emit(AccountError(failure.message)),
      (subscription) => emit(AccountSubscriptionCreated(subscription)),
    );
  }
}
