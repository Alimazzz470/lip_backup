import '../../../../core/dto/query_params.dart';
import '../../../../core/entities/vehicle/vehicle.dart';
import '../../../../core/entities/vehicle/vehicle_type.dart';
import '../../../../core/exceptions/exceptions.dart';
import '../../../../network/clients/cancel_token.dart';
import '../../../../network/data_sources/vehicle_data_source.dart';
import '../../../../shared/pagination/model.dart';
import '../../../../shared/utils/result.dart';
import 'request_vehicle_repository.dart';

class RequestVehicleRepoImpl extends RequestVehicleRepository {
  final VehicleDataSource _dataSource;

  const RequestVehicleRepoImpl({
    required VehicleDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  FutureResult<PaginatedResponse<Vehicle>> getVehicles({
    QueryParams? params,
    CancellationToken? cancelToken,
  }) async {
    try {
      final result = await _dataSource.getVehicles(
        params: params,
        cancelToken: cancelToken,
      );

      return Success(result);
    } on RequestCanceledException {
      return const Canceled();
    } catch (e, stackTrace) {
      if (e is CodedException) {
        return Failure(e, stackTrace);
      }
      return Failure(UnknownException(e.toString()), stackTrace);
    }
  }

  @override
  FutureResult<List<VehicleType>> getVehicleTypes({
    CancellationToken? cancelToken,
  }) async {
    try {
      final result = await _dataSource.getVehicleTypes(
        cancelToken: cancelToken,
      );

      return Success(result);
    } on RequestCanceledException {
      return const Canceled();
    } catch (e, stackTrace) {
      if (e is CodedException) {
        return Failure(e, stackTrace);
      }
      return Failure(UnknownException(e.toString()), stackTrace);
    }
  }

  @override
  FutureResult<Vehicle?> vehicleAssigned({
    CancellationToken? cancelToken,
  }) async {
    try {
      final result = await _dataSource.vehicleAssigned(
        cancelToken: cancelToken,
      );

      return Success(result);
    } on RequestCanceledException {
      return const Canceled();
    } catch (e, stackTrace) {
      if (e is CodedException) {
        return Failure(e, stackTrace);
      }
      return Failure(UnknownException(e.toString()), stackTrace);
    }
  }

  @override
  FutureVoid requestVehicle({
    required String vehicleTypeId,
    CancellationToken? cancelToken,
  }) async {
    try {
      await _dataSource.requestVehicle(
        vehicleId: vehicleTypeId,
        cancelToken: cancelToken,
      );

      return Success(null);
    } on RequestCanceledException {
      return const Canceled();
    } catch (e, stackTrace) {
      if (e is CodedException) {
        return Failure(e, stackTrace);
      }
      return Failure(UnknownException(e.toString()), stackTrace);
    }
  }
}
