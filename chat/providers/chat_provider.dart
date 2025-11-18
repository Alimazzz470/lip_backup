import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/entities/chat/chat_details.dart';
import '../../../core/entities/chat/chat_message.dart';
import '../../../shared/utils/result.dart';
import '../providers.dart';

final chatDetailsProvider = AsyncNotifierFamilyProvider.autoDispose<
    ChatDetailsNotifier, ChatDetails, String>(ChatDetailsNotifier.new);

class ChatDetailsNotifier
    extends AutoDisposeFamilyAsyncNotifier<ChatDetails, String> {
  @override
  FutureOr<ChatDetails> build(String arg) {
    return _load(arg);
  }

  Future<ChatDetails> _load(String chatId) async {
    final _chatRepository = ref.read(chatRepositoryProvider);

    state = const AsyncLoading();

    var res = await _chatRepository.getChatDetails(chatId: chatId);

    switch (res) {
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

final chatListProvider =
    AsyncNotifierProvider.autoDispose<ChatListNotifier, List<ChatDetails>>(
        ChatListNotifier.new);

class ChatListNotifier extends AutoDisposeAsyncNotifier<List<ChatDetails>> {
  @override
  build() {
    return _load();
  }

  Future<List<ChatDetails>> _load() async {
    final _chatRepository = ref.read(chatRepositoryProvider);

    state = const AsyncLoading();

    var res = await _chatRepository.getChats();

    switch (res) {
      case Success s:
        // sort the data by last message date
        state = AsyncData(s.value);
        return s.value;
      case Failure e:
        state = AsyncError(e.exception, e.stackTrace);
        return Future.error(e.exception, e.stackTrace);
      case Canceled _:
        return Future.error("");
    }
  }

  void tryUpdateLastMessage(String chatId, ChatMessage? message) {
    if (message == null) return;

    var current = state.asData?.value;
    if (current != null) {
      var chatList = List<ChatDetails>.from(state.value!);
      var index = chatList.indexWhere((e) => e.id == chatId);
      if (index != -1) {
        chatList[index] = chatList[index].replaceLastMessage(message);
        state = AsyncData(chatList);
      } else {
        ref.invalidateSelf();
      }
    }
  }

  void upateChatDetails(ChatDetails? chat) {
    if (chat == null) return;

    var current = state.asData?.value;
    if (current != null) {
      var chatList = List<ChatDetails>.from(state.value!);
      var index = chatList.indexWhere((e) => e.id == chat.id);
      if (index != -1) {
        chatList[index] = chatList[index].replaceUnreadCount(
          userUnreadCount: chat.userUnreadCount,
          adminUnreadCount: chat.adminUnreadCount,
        );
        chatList[index] = chatList[index].replaceChatTime(DateTime.now());
        state = AsyncData(chatList);
      } else {
        ref.invalidateSelf();
      }
    }
  }
}
