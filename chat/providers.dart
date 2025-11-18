import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../network/data_sources/chat_data_source.dart';
import '../../network/network.dart';
import 'repositories/chat_repository.dart';
import 'repositories/chat_repository_impl.dart';

final chatDataSourceProvider = Provider.autoDispose(
  (ref) => ChatDataSource(ref.watch(apiClient)),
);

final chatRepositoryProvider = Provider.autoDispose<ChatRepository>(
  (ref) => ChatRepoImpl(
    dataSource: ref.watch(chatDataSourceProvider),
  ),
);
