import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../network/data_sources/notification_data_source.dart';
import '../../../network/network.dart';
import '../repositories/notifications_repository.dart';
import '../repositories/notifications_repository_impl.dart';

final notificationsDataSourceProvider = Provider.autoDispose(
  (ref) => NotificationsDataSource(ref.watch(apiClient)),
);

final notificationsRepositoryProvider = Provider.autoDispose<NotificationsRepository>(
  (ref) => NotificationRepositoryRepoImpl(
    // connectivity: ref.watch(connectivityProvider),
    dataSource: ref.watch(notificationsDataSourceProvider),
  ),
);
