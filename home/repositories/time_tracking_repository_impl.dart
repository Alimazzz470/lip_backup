import '../../../core/dto/query_params.dart';
import '../../../core/entities/inspection.dart';
import '../../../core/entities/time_tracking/driver_logs.dart';
import '../../../core/entities/time_tracking_status.dart';
import '../../../core/exceptions/coded_exception.dart';
import '../../../core/exceptions/request_canceled_exception.dart';
import '../../../core/exceptions/unknown_exception.dart';
import '../../../network/clients/cancel_token.dart';
import '../../../network/data_sources/time_tracking_data_source.dart';
import '../../../shared/pagination/model.dart';
import '../../../shared/utils/result.dart';
import 'time_tracking_repository.dart';

class TimeTrackingRepoImpl extends TimeTrackingRepository {
  final TimeTrackingDataSource _dataSource;

  const TimeTrackingRepoImpl({
    required TimeTrackingDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  FutureResult<TimeTrackingStatus> getStatus() async {
    try {
      final result = await _dataSource.getStatus();

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
  FutureResult<String> startTracking(String startKm, String startTime) async {
    try {
      final result = await _dataSource.startTracking(startKm, startTime);

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
  FutureVoid stopTracking(String endKm, String endTime) async {
    try {
      await _dataSource.stopTracking(endKm, endTime);

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
  FutureVoid startBreak(String startTime) async {
    try {
      await _dataSource.startBreak(startTime);

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
  FutureVoid stopBreak(String endTime) async {
    try {
      await _dataSource.stopBreak(endTime);

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
  FutureResult<PaginatedResponse<DriverLog>> getDriverLogs(
    QueryParams? params, [
    CancellationToken? cancelToken,
  ]) async {
    try {
      final result = await _dataSource.getDriverLogs(
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
  FutureVoid downloadDriverLogs({
    required String downloadPath,
    QueryParams? params,
    CancellationToken? cancelToken,
  }) async {
    try {
      await _dataSource.downloadLogs(
        downloadPath: downloadPath,
        params: params,
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
  FutureResult<Inspection> inspectionAvailability([
    CancellationToken? cancelToken,
  ]) async {
    try {
      final result = await _dataSource.getInspectionAvailability(
        cancelToken,
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
  FutureResult<bool> timeTrackingSignature({
    required String timeTrackingId,
    required String confirmationId,
    CancellationToken? cancelToken,
  }) async {
    try {
      final result = await _dataSource.timeTrackingSignature(
        timeTrackingId,
        confirmationId,
        cancelToken,
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
}
