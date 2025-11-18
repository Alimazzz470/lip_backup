import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/dto/query_params.dart';
import '../../../core/entities/bonus.dart';
import '../../../network/clients/cancel_token.dart';
import '../../../shared/pagination/model.dart';
import '../../../shared/utils/date_time.dart';
import '../../../shared/utils/result.dart';
import '../dto/filter.dart';
import '../providers.dart';
import 'filter_providers.dart';

final bonusProvider =
    AsyncNotifierProvider.autoDispose<BonusNotifier, ResponseDTO<Bonus>>(
        BonusNotifier.new);

class BonusNotifier extends AutoDisposeAsyncNotifier<ResponseDTO<Bonus>> {
  int _page = 1;
  bool _hasNextPage = true;
  late final Set<Bonus> _data = {};
  FilterDto _filterDto = FilterDto.empty();

  final List<CancellationToken> _tokens = [];

  @override
  FutureOr<ResponseDTO<Bonus>> build() {
    ref.onRemoveListener(_cancelPendingTasks);

    final filters = ref.watch(filterProvider);
    _filterDto = filters;

    _page = 1;
    _hasNextPage = true;
    _data.clear();
    _cancelPendingTasks();

    return _load();
  }

  Future<ResponseDTO<Bonus>> _load() async {
    final _cancelToken = CancellationToken();

    final profileRepository = ref.read(profileRepositoryProvider);

    if (!_hasNextPage) {
      return state.asData?.value ?? ResponseDTO.empty();
    }

    var props = QueryParams(
      page: _page,
      fromDate: _filterDto.startDate?.dateText,
      toDate: _filterDto.endDate?.dateText,
    );

    _tokens.add(_cancelToken);
    final res = await profileRepository.getBonuses(
      props,
      _tokens.last,
    );
    _tokens.remove(_cancelToken);

    switch (res) {
      case Success s:
        var value = s.value as PaginatedResponse<Bonus>;
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

final getSingleBonusProvider = AsyncNotifierFamilyProvider.autoDispose<
    GetSingleBonusNotifier, Bonus, String>(GetSingleBonusNotifier.new);

class GetSingleBonusNotifier
    extends AutoDisposeFamilyAsyncNotifier<Bonus, String> {
  @override
  FutureOr<Bonus> build(String arg) {
    return _build(arg);
  }

  Future<Bonus> _build(String bonusId) async {
    final bonusRepository = ref.read(bonusRepositoryProvider);
    final res = await bonusRepository.getSingleBonus(bonusId: bonusId);
    switch (res) {
      case Success s:
        var value = s.value as Bonus;
        state = AsyncData(value);
        return value;
      case Failure e:
        state = AsyncError(e.exception, e.stackTrace);
        return Future.error(e.exception, e.stackTrace);
      case Canceled _:
        return Bonus.empty();
    }
  }
}
