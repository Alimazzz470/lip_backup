import '../../../core/dto/query_params.dart';
import '../../../core/entities/inspection.dart';
import '../../../core/entities/time_tracking/driver_logs.dart';
import '../../../core/entities/time_tracking_status.dart';
import '../../../network/clients/cancel_token.dart';
import '../../../shared/pagination/model.dart';
import '../../../shared/utils/result.dart';

abstract class TimeTrackingRepository {
  const TimeTrackingRepository();

  FutureResult<TimeTrackingStatus> getStatus();

  FutureResult<String> startTracking(String startKm, String startTime);

  FutureVoid stopTracking(String endKm, String endTime);

  FutureVoid startBreak(String startTime);

  FutureVoid stopBreak(String endTime);

  FutureResult<PaginatedResponse<DriverLog>> getDriverLogs(
    QueryParams? params, [
    CancellationToken? cancelToken,
  ]);

  FutureResult<void> downloadDriverLogs({
    required String downloadPath,
    QueryParams? params,
    CancellationToken? cancelToken,
  });

  FutureResult<Inspection> inspectionAvailability([
    CancellationToken? cancelToken,
  ]);

  FutureResult<bool> timeTrackingSignature({
    required String timeTrackingId,
    required String confirmationId,
    CancellationToken? cancelToken,
  });
}
