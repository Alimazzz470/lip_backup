import 'package:taxiapp_mobile/core/dto/query_params.dart';
import 'package:taxiapp_mobile/core/entities/bonus.dart';
import 'package:taxiapp_mobile/network/clients/cancel_token.dart';
import 'package:taxiapp_mobile/shared/pagination/model.dart';
import 'package:taxiapp_mobile/shared/utils/result.dart';

abstract class BonusRepository {
  const BonusRepository();

  FutureResult<PaginatedResponse<Bonus>> getBonuses(
    QueryParams? params, [
    CancellationToken? cancelToken,
  ]);

  FutureResult<Bonus> getSingleBonus({required String bonusId});
}
