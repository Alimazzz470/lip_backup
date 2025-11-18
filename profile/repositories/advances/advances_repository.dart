import 'package:taxiapp_mobile/core/dto/query_params.dart';
import 'package:taxiapp_mobile/core/entities/advance.dart';
import 'package:taxiapp_mobile/network/clients/cancel_token.dart';
import 'package:taxiapp_mobile/shared/pagination/model.dart';
import 'package:taxiapp_mobile/shared/utils/result.dart';

abstract class AdvanceRepository {
  const AdvanceRepository();

  FutureResult<PaginatedResponse<Advance>> getAdvances(
    QueryParams? params, [
    CancellationToken? cancelToken,
  ]);

  FutureResult<Advance> getSingleAdvance({required String advanceId});
}
