import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../dto/filter.dart';

final modelFilterProvider = NotifierProvider.autoDispose<ModelDeductionFilterNotifier, FilterDto>(
    ModelDeductionFilterNotifier.new);

class ModelDeductionFilterNotifier extends AutoDisposeNotifier<FilterDto> {
  @override
  FilterDto build() => FilterDto.empty();

  void initialize(FilterDto initial) {
    state = initial;
  }

  void setStartDate(DateTime startDate) {
    state = state.copyWith(startDate: startDate);
  }

  void setEndDate(DateTime endDate) {
    state = state.copyWith(endDate: endDate);
  }

  void setDto(FilterDto dto) {
    state = dto;
  }
}

final filterProvider =
    NotifierProvider.autoDispose<DeductionFilterNotifier, FilterDto>(DeductionFilterNotifier.new);

class DeductionFilterNotifier extends AutoDisposeNotifier<FilterDto> {
  @override
  build() => FilterDto.empty();

  void setFilters(FilterDto dto) {
    state = state.copyWith(
      startDate: dto.startDate,
      endDate: dto.endDate,
    );
  }

  void clearAllFilters() {
    ref.invalidateSelf();
  }
}
