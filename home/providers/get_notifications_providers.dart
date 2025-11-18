import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/dto/query_params.dart';
import '../../../core/entities/notifications/notifications.dart';
import '../../../network/clients/cancel_token.dart';
import '../../../shared/pagination/model.dart';
import '../../../shared/utils/result.dart';
import 'notification_providers.dart';

final notificationsProvider = AsyncNotifierProvider.autoDispose<
    AllNotificationsNotifier,
    ResponseDTO<Notifications>>(AllNotificationsNotifier.new);

class AllNotificationsNotifier
    extends AutoDisposeAsyncNotifier<ResponseDTO<Notifications>> {
  int _page = 1;
  bool _hasNextPage = true;
  late final Set<Notifications> _data = {};

  final List<CancellationToken> _tokens = [];

  @override
  FutureOr<ResponseDTO<Notifications>> build() {
    ref.onRemoveListener(_cancelPendingTasks);

    // final filters = ref.watch(leaveFilterProvider);
    // _filterDto = filters;

    _page = 1;
    _hasNextPage = true;
    _data.clear();
    _cancelPendingTasks();

    return _load();
  }

  Future<ResponseDTO<Notifications>> _load() async {
    var _cancelToken = CancellationToken();

    final notificationProvider = ref.read(notificationsRepositoryProvider);

    if (!_hasNextPage) {
      return state.asData?.value ?? ResponseDTO.empty();
    }

    var props = QueryParams(
      page: _page,
    );

    _tokens.add(_cancelToken);
    var res = await notificationProvider.getNotifications(
      props,
      _tokens.last,
    );
    _tokens.remove(_cancelToken);

    switch (res) {
      case Success s:
        var value = s.value as PaginatedResponse<Notifications>;
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

  Future<void> markAllAsRead({required DateTime dateTime}) async {
    state = const AsyncLoading();
    final notificationProvider = ref.read(notificationsRepositoryProvider);
    await notificationProvider.markAllAsRead(dateTime: dateTime);
    await refresh();
  }

  Future<void> markAsRead({required String id}) async {
    state = const AsyncLoading();
    final notificationProvider = ref.read(notificationsRepositoryProvider);
    await notificationProvider.markAsRead(id: id);
    ref.invalidateSelf();
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
