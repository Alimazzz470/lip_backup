import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../network/data_sources/leaves_data_source.dart';
import '../../network/network.dart';
import 'repositories/leaves_repository.dart';
import 'repositories/leaves_repository_impl.dart';

final leavesDataSourceProvider = Provider.autoDispose(
  (ref) => LeavesDataSource(ref.watch(apiClient)),
);

final leavesRepositoryProvider = Provider.autoDispose<LeavesRepository>(
  (ref) => LeavesRepoImpl(
    // connectivity: ref.watch(connectivityProvider),
    dataSource: ref.watch(leavesDataSourceProvider),
  ),
);
