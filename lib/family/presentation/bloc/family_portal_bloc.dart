import 'package:flutter_bloc/flutter_bloc.dart';

import '../../application/queries/get_family_portal_query.dart';
import '../../domain/entities/family_portal_data.dart';

abstract class FamilyPortalEvent {}

class LoadFamilyPortalEvent extends FamilyPortalEvent {
  final int userId;

  LoadFamilyPortalEvent(this.userId);
}

abstract class FamilyPortalState {}

class FamilyPortalInitial extends FamilyPortalState {}

class FamilyPortalLoading extends FamilyPortalState {}

class FamilyPortalLoaded extends FamilyPortalState {
  final FamilyPortalData data;

  FamilyPortalLoaded(this.data);
}

class FamilyPortalUnlinked extends FamilyPortalState {
  final String message;

  FamilyPortalUnlinked(this.message);
}

class FamilyPortalError extends FamilyPortalState {
  final String message;

  FamilyPortalError(this.message);
}

class FamilyPortalBloc extends Bloc<FamilyPortalEvent, FamilyPortalState> {
  final GetFamilyPortalQuery _query;

  FamilyPortalBloc(this._query) : super(FamilyPortalInitial()) {
    on<LoadFamilyPortalEvent>((event, emit) async {
      emit(FamilyPortalLoading());
      final result = await _query.execute(event.userId);
      result.fold(
        (failure) => failure.code == '404'
            ? emit(FamilyPortalUnlinked(failure.message))
            : emit(FamilyPortalError(failure.message)),
        (data) => emit(FamilyPortalLoaded(data)),
      );
    });
  }
}
