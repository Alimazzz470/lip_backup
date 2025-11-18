import 'package:taxiapp_mobile/core/dto/query_params.dart';
import 'package:taxiapp_mobile/core/entities/advance.dart';
import 'package:taxiapp_mobile/core/exceptions/coded_exception.dart';
import 'package:taxiapp_mobile/core/exceptions/request_canceled_exception.dart';
import 'package:taxiapp_mobile/core/exceptions/unknown_exception.dart';
import 'package:taxiapp_mobile/features/profile/repositories/advances/advances_repository.dart';
import 'package:taxiapp_mobile/network/clients/cancel_token.dart';
import 'package:taxiapp_mobile/network/data_sources/profile_data_source.dart';
import 'package:taxiapp_mobile/shared/pagination/model.dart';
import 'package:taxiapp_mobile/shared/utils/result.dart';

class AdvanceRepositoryImpl extends AdvanceRepository {
  final ProfileDataSource _dataSource;

  const AdvanceRepositoryImpl({
    required ProfileDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  FutureResult<PaginatedResponse<Advance>> getAdvances(QueryParams? params,
      [CancellationToken? cancelToken]) async {
    try {
      final result = await _dataSource.getAdvances(
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
  FutureResult<Advance> getSingleAdvance({required String advanceId}) async {
    try {
      return Success(await _dataSource.getSingleAdvance(advanceId: advanceId));
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
