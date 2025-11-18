import '../../../core/dto/query_params.dart';
import '../../../core/entities/leaves/leave.dart';
import '../../../core/entities/leaves/leave_type.dart';
import '../../../core/exceptions/coded_exception.dart';
import '../../../core/exceptions/request_canceled_exception.dart';
import '../../../core/exceptions/unknown_exception.dart';
import '../../../network/clients/cancel_token.dart';
import '../../../network/data_sources/leaves_data_source.dart';
import '../../../shared/pagination/model.dart';
import '../../../shared/utils/result.dart';
import 'leaves_repository.dart';

class LeavesRepoImpl extends LeavesRepository {
  final LeavesDataSource _dataSource;

  const LeavesRepoImpl({
    required LeavesDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  FutureVoid requestLeave({
    required String type,
    required String reason,
    required String startDate,
    required String endDate,
    CancellationToken? cancelToken,
  }) async {
    try {
      await _dataSource.requestLeave(
        type: type,
        reason: reason,
        startDate: startDate,
        endDate: endDate,
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
  FutureResult<List<LeaveType>> getLeaveTypes({
    CancellationToken? cancelToken,
  }) async {
    try {
      final result = await _dataSource.getLeaveTypes(
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
  FutureResult<PaginatedResponse<Leave>> getLeaves(
    QueryParams? params, [
    CancellationToken? cancelToken,
  ]) async {
    try {
      final result = await _dataSource.getLeaves(
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
}
