import '../../../../core/exceptions/exceptions.dart';
import '../../../../network/clients/cancel_token.dart';
import '../../../../network/data_sources/vehicle_data_source.dart';
import '../../../../shared/utils/result.dart';
import 'inspection_repository.dart';

class InspectionRepoImpl extends InspectionRepository {
  final VehicleDataSource _dataSource;

  const InspectionRepoImpl({
    required VehicleDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  FutureVoid returnVehicle({
    required int kms,
    required String vehicleTypeId,
    required String confirmationId,
    required String signatureId,
    CancellationToken? cancelToken,
  }) async {
    try {
      await _dataSource.returnVehicle(
        kms: kms,
        vehicleId: vehicleTypeId,
        confirmationId: confirmationId,
        signatureId: signatureId,
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

  @override
  FutureVoid monthlyInspection({
    required String inspectionId,
    required int kms,
    required String vehicleTypeId,
    required String confirmationId,
    required String signatureId,
    CancellationToken? cancelToken,
  }) async {
    try {
      await _dataSource.monthlyInspection(
        inspectionId: inspectionId,
        kms: kms,
        vehicleId: vehicleTypeId,
        confirmationId: confirmationId,
        signatureId: signatureId,
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
