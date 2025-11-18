import '../../../../network/clients/cancel_token.dart';
import '../../../../shared/utils/result.dart';

abstract class InspectionRepository {
  const InspectionRepository();

  FutureVoid returnVehicle({
    required int kms,
    required String vehicleTypeId,
    required String confirmationId,
    required String signatureId,
    CancellationToken? cancelToken,
  });

  FutureVoid monthlyInspection({
    required String inspectionId,
    required int kms,
    required String vehicleTypeId,
    required String confirmationId,
    required String signatureId,
    CancellationToken? cancelToken,
  });
}
