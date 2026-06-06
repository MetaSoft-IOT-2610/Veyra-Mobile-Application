import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/staff_member.dart';
import '../../application/queries/get_active_staff_query.dart';

abstract class StaffEvent {}
class LoadActiveStaffEvent extends StaffEvent {
  final int nursingHomeId;
  LoadActiveStaffEvent(this.nursingHomeId);
}

abstract class StaffState {}
class StaffInitial extends StaffState {}
class StaffLoading extends StaffState {}
class StaffLoaded extends StaffState {
  final List<StaffMember> staffMembers;
  StaffLoaded(this.staffMembers);
}
class StaffError extends StaffState {
  final String message;
  StaffError(this.message);
}

class StaffBloc extends Bloc<StaffEvent, StaffState> {
  final GetActiveStaffQuery _getActiveStaffQuery;

  StaffBloc(this._getActiveStaffQuery) : super(StaffInitial()) {
    on<LoadActiveStaffEvent>((event, emit) async {
      emit(StaffLoading());
      final result = await _getActiveStaffQuery.execute(event.nursingHomeId);
      result.fold(
            (failure) => emit(StaffError(failure.message)),
            (staff) => emit(StaffLoaded(staff)),
      );
    });
  }
}
