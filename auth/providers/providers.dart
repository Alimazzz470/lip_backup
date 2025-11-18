import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../network/data_sources/authentication_data_source.dart';
import '../../../network/network.dart';
import '../repositories/auth_repository.dart';
import '../repositories/auth_repository_impl.dart';

final authenticationDataSource = Provider.autoDispose(
  (ref) => AuthenticationDataSource(ref.watch(apiClient)),
);

final authenticationRepository = Provider.autoDispose<AuthenticationRepository>(
  (ref) => AuthenticationRepoImpl(
    // connectivity: ref.watch(connectivityProvider),
    dataSource: ref.watch(authenticationDataSource),
    tokenDataSource: ref.watch(tokenDataSource),
  ),
);
