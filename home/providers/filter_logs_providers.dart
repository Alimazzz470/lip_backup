import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../dto/log_filter.dart';

final modelLogFilterProvider = NotifierProvider.autoDispose<ModelLeaveFilterNotifier, LogFilterDto>(
    ModelLeaveFilterNotifier.new);

class ModelLeaveFilterNotifier extends AutoDisposeNotifier<LogFilterDto> {
  @override
  LogFilterDto build() => LogFilterDto.empty();

  void initialize(LogFilterDto initial) {
    state = initial;
  }

  void setStartDate(DateTime startDate) {
    state = state.copyWith(startDate: startDate);
  }

  void setEndDate(DateTime endDate) {
    state = state.copyWith(endDate: endDate);
  }
}

final logFilterProvider =
    NotifierProvider.autoDispose<LeaveFilterNotifier, LogFilterDto>(LeaveFilterNotifier.new);

class LeaveFilterNotifier extends AutoDisposeNotifier<LogFilterDto> {
  @override
  build() => LogFilterDto.empty();

  void setFilters(LogFilterDto dto) {
    state = state.copyWith(
      startDate: dto.startDate,
      endDate: dto.endDate,
    );
  }

  void clearAllFilters() {
    ref.invalidateSelf();
  }
}
