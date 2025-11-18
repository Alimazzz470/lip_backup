import 'package:taxiapp_mobile/core/dto/query_params.dart';
import 'package:taxiapp_mobile/core/entities/penalty.dart';
import 'package:taxiapp_mobile/network/clients/cancel_token.dart';
import 'package:taxiapp_mobile/shared/pagination/model.dart';
import 'package:taxiapp_mobile/shared/utils/result.dart';

abstract class PenaltyRepository {
  const PenaltyRepository();

  FutureResult<PaginatedResponse<Penalty>> getPenalties(
    QueryParams? params, [
    CancellationToken? cancelToken,
  ]);

  FutureResult<Penalty> getSinglePenalty({required String penaltyId});
}
