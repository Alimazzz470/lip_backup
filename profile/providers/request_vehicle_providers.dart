import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taxiapp_mobile/features/home/providers/inspection_provider.dart';
import '../../../core/dto/option.dart';
import '../../../core/dto/query_params.dart';
import '../../../core/entities/vehicle/vehicle.dart';
import '../../../network/clients/cancel_token.dart';
import '../../../shared/pagination/model.dart';
import '../../../shared/providers/common_providers.dart';
import '../../../shared/utils/result.dart';
import '../../../shared/utils/typedef.dart';
import '../providers.dart';
import '../repositories/request_vehicle/request_vehicle_repository.dart';
import 'profile_providers.dart';
import 'search_vehicle_provider.dart';

final vehicleTypeProvider =
    FutureProvider.autoDispose<List<Option>>((ref) async {
  final requestVehicleRepository = ref.watch(requestVehicleRepositoryProvider);

  final result = await requestVehicleRepository.getVehicleTypes();

  switch (result) {
    case Success(value: final vehicleTypes):
      return vehicleTypes
          .map((type) => Option(value: type.id, label: type.name))
          .toList();
    case Failure(exception: final exception):
      debugPrint(exception.message.toString());
      return [];
    case Canceled():
      return [];
  }
});

final vehiclesProvider =
    AsyncNotifierProvider.autoDispose<VehiclesNotifier, ResponseDTO<Vehicle>>(
        VehiclesNotifier.new);

class VehiclesNotifier extends AutoDisposeAsyncNotifier<ResponseDTO<Vehicle>> {
  int _page = 1;
  bool _hasNextPage = true;
  late final Set<Vehicle> _data = {};

  final List<CancellationToken> _tokens = [];

  @override
  FutureOr<ResponseDTO<Vehicle>> build() {
    ref.onRemoveListener(_cancelPendingTasks);

    var query = ref.watch(searchVehicleProvider);
    _page = 1;
    _hasNextPage = true;
    _data.clear();
    _cancelPendingTasks();

    return _load(query);
  }

  Future<ResponseDTO<Vehicle>> _load([SearchVehicleDTO? searchQuery]) async {
    var _cancelToken = CancellationToken();

    if (!_hasNextPage) {
      return state.asData?.value ?? ResponseDTO.empty();
    }

    var props = QueryParams(
      page: _page,
      vehicleTypeId: searchQuery?.vehicleTypeId,
      vehicleNumber: searchQuery?.vehicleNumber,
    );

    _tokens.add(_cancelToken);
    var res = await ref.read(requestVehicleRepositoryProvider).getVehicles(
          params: props,
          cancelToken: _tokens.last,
        );
    _tokens.remove(_cancelToken);

    switch (res) {
      case Success s:
        var value = s.value as PaginatedResponse<Vehicle>;
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

final requestVehicleProvider =
    NotifierProvider.autoDispose<RequestVehicleNotifier, bool>(
        RequestVehicleNotifier.new);

class RequestVehicleNotifier extends AutoDisposeNotifier<bool> {
  late final RequestVehicleRepository _repository;
  late final AppMessage _appMessage;

  @override
  bool build() {
    _repository = ref.read(requestVehicleRepositoryProvider);
    _appMessage = ref.read(appMessageProvider.notifier);

    return false;
  }

  void requestVehicle({
    required String vehicleTypeId,
    required OnSuccessVoidCallback onSuccess,
  }) async {
    state = true;

    final result = await _repository.requestVehicle(
      vehicleTypeId: vehicleTypeId,
    );
    state = false;

    switch (result) {
      case Success(value: final _):
        ref.invalidate(vehiclesProvider);
        ref.invalidate(hasInspectionProvider);
        ref.invalidate(assignedVehicleProvider);
        onSuccess();
      case Failure(exception: final exception):
        _appMessage.addException(exception: exception);
      case Canceled():
        break;
    }
  }
}
