import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../network/data_sources/time_tracking_data_source.dart';
import '../../network/network.dart';
import 'repositories/time_tracking_repository.dart';
import 'repositories/time_tracking_repository_impl.dart';

final timeTrackingDataSourceProvider = Provider.autoDispose(
  (ref) => TimeTrackingDataSource(ref.watch(apiClient)),
);

final timeTrackingRepositoryProvider = Provider.autoDispose<TimeTrackingRepository>(
  (ref) => TimeTrackingRepoImpl(
    dataSource: ref.watch(timeTrackingDataSourceProvider),
  ),
);
