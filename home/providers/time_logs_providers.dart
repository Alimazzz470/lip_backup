import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/dto/query_params.dart';
import '../../../core/entities/time_tracking/driver_logs.dart';
import '../../../network/clients/cancel_token.dart';
import '../../../shared/pagination/model.dart';
import '../../../shared/providers/common_providers.dart';
import '../../../shared/utils/date_time.dart';
import '../../../shared/utils/result.dart';
import '../../../shared/utils/typedef.dart';
import '../dto/log_filter.dart';
import '../dto/today_log.dart';
import '../providers.dart';
import 'filter_logs_providers.dart';

final timeLogsProvider =
    AsyncNotifierProvider.autoDispose<TimeLogsNotifier, ResponseDTO<DriverLog>>(
        TimeLogsNotifier.new);

class TimeLogsNotifier
    extends AutoDisposeAsyncNotifier<ResponseDTO<DriverLog>> {
  int _page = 1;
  bool _hasNextPage = true;
  late final Set<DriverLog> _data = {};
  LogFilterDto _filterDto = LogFilterDto.empty();

  final List<CancellationToken> _tokens = [];

  @override
  FutureOr<ResponseDTO<DriverLog>> build() {
    ref.onRemoveListener(_cancelPendingTasks);

    final filters = ref.watch(logFilterProvider);
    _filterDto = filters;

    _page = 1;
    _hasNextPage = true;
    _data.clear();
    _cancelPendingTasks();

    return _load();
  }

  Future<ResponseDTO<DriverLog>> _load() async {
    var _cancelToken = CancellationToken();

    final timeTrackingRepository = ref.read(timeTrackingRepositoryProvider);

    if (!_hasNextPage) {
      return state.asData?.value ?? ResponseDTO.empty();
    }

    var props = QueryParams(
      page: _page,
      fromDate: _filterDto.startDate?.dateText,
      toDate: _filterDto.endDate?.dateText,
    );

    _tokens.add(_cancelToken);
    var res = await timeTrackingRepository.getDriverLogs(
      props,
      _tokens.last,
    );
    _tokens.remove(_cancelToken);

    switch (res) {
      case Success s:
        var value = s.value as PaginatedResponse<DriverLog>;
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

final todayLogProvider =
    FutureProvider.autoDispose<List<TodayLogDto>>((ref) async {
  final timeTrackingRepository = ref.watch(timeTrackingRepositoryProvider);
  final result = await timeTrackingRepository.getDriverLogs(
    QueryParams(
      fromDate: DateTime.now().toIso8601String(),
    ),
  );

  switch (result) {
    case Success(value: final log):
      return log.data.isEmpty ? [] : _getTimeline(log.data.first);
    case Failure(exception: final _):
      return [];
    case Canceled():
      return [];
  }
});

final timelineProvider =
    StateProvider.family<List<TodayLogDto>, DriverLog>((ref, logs) {
  return _getTimeline(logs);
});

List<TodayLogDto> _getTimeline(DriverLog log) {
  List<TodayLogDto> _timeline = [];

  _timeline.add(TodayLogDto(
    startTime: log.startTime?.timeOnly,
  ));

  for (var breakTime in log.breaks) {
    _timeline.add(TodayLogDto(
      breakStarted: breakTime.breakStarted?.timeOnly,
      breakEnded: breakTime.breakEnded?.timeOnly,
    ));

    if (breakTime.breakEnded != null) {
      _timeline.add(TodayLogDto(
        startTime: breakTime.breakEnded?.timeOnly,
      ));
    }
  }

  if (log.endTime != null) {
    _timeline.add(TodayLogDto(
      endTime: log.endTime?.timeOnly,
    ));
  }

  return _timeline;
}

final downloadLogsProvider =
    NotifierProvider.autoDispose<DownloadLogsNotifier, bool>(
        DownloadLogsNotifier.new);

class DownloadLogsNotifier extends AutoDisposeNotifier<bool> {
  late final AppMessage _appMessage;

  @override
  build() {
    _appMessage = ref.read(appMessageProvider.notifier);

    return false;
  }

  Future<void> download(
    String path, {
    DateTime? startDate,
    DateTime? endDate,
    required OnSuccessVoidCallback onSuccess,
  }) async {
    final timeTrackingRepository = ref.watch(timeTrackingRepositoryProvider);

    state = true;

    final result = await timeTrackingRepository.downloadDriverLogs(
      downloadPath: path,
      params: QueryParams(
        startDate: startDate?.toIso8601String(),
        endDate: endDate?.toIso8601String(),
      ),
    );
    state = false;

    switch (result) {
      case Success _:
        onSuccess();
      case Failure(exception: final e):
        _appMessage.addException(exception: e);
      case Canceled():
        break;
    }
  }
}
