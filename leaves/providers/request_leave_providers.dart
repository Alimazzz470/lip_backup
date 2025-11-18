import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/common_providers.dart';
import '../../../shared/utils/date_time.dart';
import '../../../shared/utils/result.dart';
import '../../../shared/utils/typedef.dart';
import '../dto/request_leave.dart';
import '../providers.dart';
import '../repositories/leaves_repository.dart';

final setLeaveDetailsProvider =
    StateNotifierProvider.autoDispose<SetLeaveDetailsNotifier, RequestLeaveDto>((ref) {
  return SetLeaveDetailsNotifier();
});

class SetLeaveDetailsNotifier extends StateNotifier<RequestLeaveDto> {
  SetLeaveDetailsNotifier() : super(const RequestLeaveDto.empty());

  void setStartDate(DateTime date) {
    final currentEndDate = state.endDate?.dateOnly ?? date.dateOnly;
    state = state.copyWith(
      startDate: date.dateOnly,
      endDate: date.isEqualOrAfter(currentEndDate) ? date.dateOnly : currentEndDate,
    );
  }

  void setEndDate(DateTime date) {
    state = state.copyWith(
      endDate: date.dateOnly,
    );
  }

  void setReason(String reason) {
    state = state.copyWith(reason: reason);
  }

  void setType(String type) {
    state = state.copyWith(type: type);
  }
}

final requestLeavesProvider = StateNotifierProvider.autoDispose<RequestLeavesNotifier, bool>(
  (ref) {
    return RequestLeavesNotifier(
      leavesRepository: ref.watch(leavesRepositoryProvider),
      appMessage: ref.watch(appMessageProvider.notifier),
    );
  },
);

class RequestLeavesNotifier extends StateNotifier<bool> {
  final LeavesRepository _leavesRepository;
  final AppMessage _appMessage;

  RequestLeavesNotifier({
    required LeavesRepository leavesRepository,
    required AppMessage appMessage,
  })  : _leavesRepository = leavesRepository,
        _appMessage = appMessage,
        super(false);

  void requestLeave({
    required String type,
    required String reason,
    required String startDate,
    required String endDate,
    required OnSuccessVoidCallback onSuccess,
  }) async {
    state = true;

    final result = await _leavesRepository.requestLeave(
      type: type,
      reason: reason,
      startDate: startDate,
      endDate: endDate,
    );
    state = false;

    switch (result) {
      case Success(value: final _):
        onSuccess();
      case Failure(exception: final exception):
        _appMessage.addException(exception: exception);
      case Canceled():
        break;
    }
  }
}
