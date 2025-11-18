import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/dto/option.dart';
import '../../../core/dto/query_params.dart';
import '../../../core/entities/leaves/leave.dart';
import '../../../core/entities/leaves/leave_type.dart';
import '../../../network/clients/cancel_token.dart';
import '../../../shared/pagination/model.dart';
import '../../../shared/utils/result.dart';
import '../dto/leaves_filter.dart';
import '../providers.dart';
import 'filter_leaves_provider.dart';

final leaveTypesProvider = FutureProvider.autoDispose<List<LeaveType>>((ref) async {
  final leavesRepository = ref.watch(leavesRepositoryProvider);

  final result = await leavesRepository.getLeaveTypes();

  switch (result) {
    case Success(value: final leaveTypes):
      final typeOptions =
          leaveTypes.map((leave) => Option(value: leave.type.id, label: leave.type.name)).toList();

      ref.read(leaveOptionsStateProvider.notifier).update((state) => typeOptions);

      return leaveTypes;
    case Failure(exception: final exception):
      debugPrint(exception.message.toString());
      return [];
    case Canceled():
      return [];
  }
});

final leaveRequestProvider = FutureProvider.autoDispose<List<Leave>>((ref) async {
  final leavesRepository = ref.watch(leavesRepositoryProvider);

  final result = await leavesRepository.getLeaves(
    QueryParams(fromDate: DateTime.now().toString()),
  );

  switch (result) {
    case Success(value: final leaves):
      return leaves.data;
    case Failure(exception: final exception):
      debugPrint(exception.message.toString());
      return [];
    case Canceled():
      return [];
  }
});

final leaveHistoryProvider = FutureProvider.autoDispose<List<Leave>>((ref) async {
  final leavesRepository = ref.watch(leavesRepositoryProvider);

  final result = await leavesRepository.getLeaves(
    QueryParams(toDate: DateTime.now().toString()),
  );

  switch (result) {
    case Success(value: final leaves):
      return leaves.data;
    case Failure(exception: final exception):
      debugPrint(exception.message.toString());
      return [];
    case Canceled():
      return [];
  }
});

final leaveOptionsStateProvider = StateProvider<List<Option>>((ref) => []);

final allLeavesProvider =
    AsyncNotifierProvider.autoDispose<AllLeavesNotifier, ResponseDTO<Leave>>(AllLeavesNotifier.new);

class AllLeavesNotifier extends AutoDisposeAsyncNotifier<ResponseDTO<Leave>> {
  int _page = 1;
  bool _hasNextPage = true;
  late final Set<Leave> _data = {};
  LeavesFilterDto _filterDto = LeavesFilterDto.empty();

  final List<CancellationToken> _tokens = [];

  @override
  FutureOr<ResponseDTO<Leave>> build() {
    ref.onRemoveListener(_cancelPendingTasks);

    final filters = ref.watch(leaveFilterProvider);
    _filterDto = filters;

    _page = 1;
    _hasNextPage = true;
    _data.clear();
    _cancelPendingTasks();

    return _load();
  }

  Future<ResponseDTO<Leave>> _load() async {
    var _cancelToken = CancellationToken();

    final leavesRepository = ref.read(leavesRepositoryProvider);

    if (!_hasNextPage) {
      return state.asData?.value ?? ResponseDTO.empty();
    }

    var props = QueryParams(
      page: _page,
      fromDate: _filterDto.startDate?.toIso8601String(),
      toDate: _filterDto.endDate?.toIso8601String(),
      status: _filterDto.status?.toLowerCase(),
      leaveTypes: _filterDto.type?.value,
    );

    _tokens.add(_cancelToken);
    var res = await leavesRepository.getLeaves(
      props,
      _tokens.last,
    );
    _tokens.remove(_cancelToken);

    switch (res) {
      case Success s:
        var value = s.value as PaginatedResponse<Leave>;
        _hasNextPage = !value.isLastPage;
        if (_hasNextPage) {
          _page++;
        }
        _data.addAll(value.data);
        var dto = ResponseDTO(
          data: _data.toList(growable: false),
          hasNextPage: _hasNextPage,
          totalPages: value.pageCount,
        );
        state = AsyncData(dto);
        return dto;
      case Failure e:
        state = AsyncError(e.exception, e.stackTrace);
        return Future.error(e.exception, e.stackTrace);
      case Canceled _:
        return ResponseDTO.empty();
    }
  }

  Future<void> loadMore() async {
    await _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    _page = 1;
    _hasNextPage = true;
    _data.clear();
    ref.invalidateSelf();
  }

  ///
  /// Maintains all pending API calls and cancels them when invoked
  /// Eg: on query change previous request should be cancelled
  ///
  void _cancelPendingTasks() {
    for (var token in _tokens) {
      token.cancel();
    }
    _tokens.clear();
  }
}
