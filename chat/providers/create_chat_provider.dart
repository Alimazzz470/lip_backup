import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/entities/chat/chat_admin.dart';
import '../../../core/entities/chat/chat_details.dart';
import '../../../shared/providers/common_providers.dart';
import '../../../shared/utils/result.dart';
import '../../../shared/utils/typedef.dart';
import '../providers.dart';
import '../repositories/chat_repository.dart';

final chatAdminsProvider = AsyncNotifierFamilyProvider.autoDispose<
    ChatAdminsNotifier, List<ChatAdmin>, String>(
  ChatAdminsNotifier.new,
);

class ChatAdminsNotifier
    extends AutoDisposeFamilyAsyncNotifier<List<ChatAdmin>, String> {
  late final ChatRepository _chatRepository;

  @override
  FutureOr<List<ChatAdmin>> build(String arg) {
    _chatRepository = ref.read(chatRepositoryProvider);

    return _load(
      name: arg,
    );
  }

  Future<List<ChatAdmin>> _load({String? name}) async {
    state = const AsyncLoading();

    final result = await _chatRepository.getAllUsers(name: name);

    switch (result) {
      case Success s:
        state = AsyncData(s.value);
        return s.value;
      case Failure e:
        state = AsyncError(e.exception, e.stackTrace);
        return Future.error(e.exception, e.stackTrace);
      case Canceled _:
        return Future.error("");
    }
  }
}

final createChatProvider =
    NotifierProvider.autoDispose<CreateChatNotifier, bool>(
  CreateChatNotifier.new,
);

class CreateChatNotifier extends AutoDisposeNotifier<bool> {
  late final ChatRepository _chatRepository;
  late final AppMessage _appMessage;

  @override
  build() {
    _chatRepository = ref.read(chatRepositoryProvider);
    _appMessage = ref.read(appMessageProvider.notifier);

    return false;
  }

  void createChat(
    String adminId,
    OnSuccessCallback<ChatDetails> onSuccess,
  ) async {
    state = true;

    final result = await _chatRepository.createChat(adminId: adminId);

    state = false;

    switch (result) {
      case Success s:
        onSuccess(s.value);
        break;
      case Failure e:
        _appMessage.addException(exception: e.exception);
        return Future.error(e.exception, e.stackTrace);
      case Canceled _:
        return Future.error("");
    }
  }
}
