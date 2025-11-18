import '../../../../core/dto/query_params.dart';
import '../../../../core/entities/vehicle/vehicle.dart';
import '../../../../core/entities/vehicle/vehicle_type.dart';
import '../../../../network/clients/cancel_token.dart';
import '../../../../shared/pagination/model.dart';
import '../../../../shared/utils/result.dart';

abstract class RequestVehicleRepository {
  const RequestVehicleRepository();

  FutureResult<PaginatedResponse<Vehicle>> getVehicles({
    QueryParams? params,
    CancellationToken? cancelToken,
  });

  FutureResult<List<VehicleType>> getVehicleTypes({
    CancellationToken? cancelToken,
  });

  FutureResult<Vehicle?> vehicleAssigned({
    CancellationToken? cancelToken,
  });

  FutureVoid requestVehicle({
    required String vehicleTypeId,
    CancellationToken? cancelToken,
  });
}
