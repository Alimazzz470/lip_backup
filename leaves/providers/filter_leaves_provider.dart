import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/dto/option.dart';
import '../dto/leaves_filter.dart';

final modelLeaveFilterProvider =
    NotifierProvider.autoDispose<ModelLeaveFilterNotifier, LeavesFilterDto>(
        ModelLeaveFilterNotifier.new);

class ModelLeaveFilterNotifier extends AutoDisposeNotifier<LeavesFilterDto> {
  @override
  LeavesFilterDto build() => LeavesFilterDto.empty();

  void initialize(LeavesFilterDto initial) {
    state = initial;
  }

  void setStatus(String status) {
    state = state.copyWith(status: status);
  }

  void setType(Option type) {
    state = state.copyWith(type: type);
  }

  void setStartDate(DateTime startDate) {
    state = state.copyWith(startDate: startDate);
  }

  void setEndDate(DateTime endDate) {
    state = state.copyWith(endDate: endDate);
  }

  void setDto(LeavesFilterDto dto) {
    state = dto;
  }
}

final leaveFilterProvider =
    NotifierProvider.autoDispose<LeaveFilterNotifier, LeavesFilterDto>(LeaveFilterNotifier.new);

class LeaveFilterNotifier extends AutoDisposeNotifier<LeavesFilterDto> {
  @override
  build() => LeavesFilterDto.empty();

  void setFilters(LeavesFilterDto dto) {
    state = state.copyWith(
      status: dto.status,
      type: dto.type,
      startDate: dto.startDate,
      endDate: dto.endDate,
    );
  }

  void clearAllFilters() {
    ref.invalidateSelf();
  }
}
