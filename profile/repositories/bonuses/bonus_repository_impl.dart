import 'package:taxiapp_mobile/core/dto/query_params.dart';
import 'package:taxiapp_mobile/core/entities/bonus.dart';
import 'package:taxiapp_mobile/core/exceptions/coded_exception.dart';
import 'package:taxiapp_mobile/core/exceptions/request_canceled_exception.dart';
import 'package:taxiapp_mobile/core/exceptions/unknown_exception.dart';
import 'package:taxiapp_mobile/features/profile/repositories/bonuses/bonus_repository.dart';
import 'package:taxiapp_mobile/network/clients/cancel_token.dart';
import 'package:taxiapp_mobile/network/data_sources/profile_data_source.dart';
import 'package:taxiapp_mobile/shared/pagination/model.dart';
import 'package:taxiapp_mobile/shared/utils/result.dart';

class BonusRepositoryImpl extends BonusRepository {
  final ProfileDataSource _dataSource;

  const BonusRepositoryImpl({
    required ProfileDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  FutureResult<PaginatedResponse<Bonus>> getBonuses(QueryParams? params,
      [CancellationToken? cancelToken]) async {
    try {
      final result = await _dataSource.getBonus(
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
  FutureResult<Bonus> getSingleBonus({required String bonusId}) async {
    try {
      return Success(await _dataSource.getSingleBonus(bonusId: bonusId));
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
