import '../../../core/dto/query_params.dart';
import '../../../core/entities/notifications/notifications.dart';
import '../../../network/clients/cancel_token.dart';
import '../../../shared/pagination/model.dart';
import '../../../shared/utils/result.dart';

abstract class NotificationsRepository {
  FutureResult<PaginatedResponse<Notifications>> getNotifications(
    QueryParams? params, [
    CancellationToken? cancelToken,
  ]);

  FutureResult<void> markAllAsRead({
    required DateTime dateTime,
    CancellationToken? cancelToken,
  });

  FutureResult<void> markAsRead({
    required String id,
    CancellationToken? cancelToken,
  });
}
