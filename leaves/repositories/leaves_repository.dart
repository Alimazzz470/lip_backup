import '../../../core/dto/query_params.dart';
import '../../../core/entities/leaves/leave.dart';
import '../../../core/entities/leaves/leave_type.dart';
import '../../../network/clients/cancel_token.dart';
import '../../../shared/pagination/model.dart';
import '../../../shared/utils/result.dart';

abstract class LeavesRepository {
  const LeavesRepository();

  FutureVoid requestLeave({
    required String type,
    required String reason,
    required String startDate,
    required String endDate,
    CancellationToken? cancelToken,
  });

  FutureResult<List<LeaveType>> getLeaveTypes({
    CancellationToken? cancelToken,
  });

  FutureResult<PaginatedResponse<Leave>> getLeaves(
    QueryParams? params, [
    CancellationToken? cancelToken,
  ]);
}
