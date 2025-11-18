import '../../../core/dto/query_params.dart';
import '../../../core/entities/notifications/notifications.dart';
import '../../../core/exceptions/coded_exception.dart';
import '../../../core/exceptions/request_canceled_exception.dart';
import '../../../core/exceptions/unknown_exception.dart';
import '../../../network/clients/cancel_token.dart';
import '../../../network/data_sources/notification_data_source.dart';
import '../../../shared/pagination/model.dart';
import '../../../shared/utils/result.dart';
import 'notifications_repository.dart';

class NotificationRepositoryRepoImpl extends NotificationsRepository {
  final NotificationsDataSource _dataSource;

  NotificationRepositoryRepoImpl({
    required NotificationsDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  FutureResult<PaginatedResponse<Notifications>> getNotifications(
      QueryParams? params,
      [CancellationToken? cancelToken]) async {
    try {
      final result = await _dataSource.getNotifications(
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
  FutureResult<void> markAllAsRead(
      {required DateTime dateTime, CancellationToken? cancelToken}) async {
    try {
      await _dataSource.markAllAsRead(
        dateTime: dateTime,
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
  FutureResult<void> markAsRead(
      {required String id, CancellationToken? cancelToken}) async {
    try {
      await _dataSource.markAsRead(
        id: id,
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
}
