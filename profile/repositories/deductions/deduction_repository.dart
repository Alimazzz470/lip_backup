import 'package:taxiapp_mobile/core/dto/query_params.dart';
import 'package:taxiapp_mobile/core/entities/deduction.dart';
import 'package:taxiapp_mobile/network/clients/cancel_token.dart';
import 'package:taxiapp_mobile/shared/pagination/model.dart';
import 'package:taxiapp_mobile/shared/utils/result.dart';

abstract class DeductionRepository {
  const DeductionRepository();

  FutureResult<PaginatedResponse<Deduction>> getDeductions(
    QueryParams? params, [
    CancellationToken? cancelToken,
  ]);

  FutureResult<Deduction> getSingleDeduction({required String deductionId});
}
