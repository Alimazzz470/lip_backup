import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taxiapp_mobile/features/chat/providers/chat_provider.dart';

import '../../../core/dto/query_params.dart';
import '../../../core/entities/chat/chat_message.dart';
import '../../../core/services/image_helpers.dart';
import '../../../network/clients/cancel_token.dart';
import '../../../shared/pagination/model.dart';
import '../../../shared/providers/common_providers.dart';
import '../../../shared/providers/websocket_provider.dart';
import '../../../shared/utils/enums.dart';
import '../../../shared/utils/result.dart';
import '../chat_extensions.dart';
import '../providers.dart';

final chatMessagesProvider = AsyncNotifierProvider.family
    .autoDispose<ChatMessagesNotifier, ResponseDTO<ChatMessage>, String>(
        ChatMessagesNotifier.new);

class ChatMessagesNotifier
    extends AutoDisposeFamilyAsyncNotifier<ResponseDTO<ChatMessage>, String> {
  CancellationToken? _token;

  int _page = 1;
  bool _hasNextPage = true;
  late final List<ChatMessage> _data = [];
  late final Set<String> _uniqueMessageIds = <String>{};

  String _chatId = "";

  @override
  FutureOr<ResponseDTO<ChatMessage>> build(String arg) async {
    ref.onRemoveListener(() {
      _token?.cancel();
    });

    _chatId = arg;

    return _load();
  }

  Future<ResponseDTO<ChatMessage>> _load() async {
    if (!_hasNextPage) {
      return state.asData!.value;
    }

    final props = QueryParams(page: _page);

    _token = CancellationToken();
    final res = await ref.read(chatRepositoryProvider).getMessages(
          chatId: _chatId,
          params: props,
        );
    _token = null;

    switch (res) {
      case Success s:
        final value = s.value as PaginatedResponse<ChatMessage>;
        _hasNextPage = !value.isLastPage;
        if (_hasNextPage) {
          _page++;
        }

        for (final message in value.data) {
          if (!_uniqueMessageIds.contains(message.id)) {
            _data.add(message);
            _uniqueMessageIds.add(message.id);
          }
        }

        final dto = ResponseDTO(
          data: _data.toList(growable: false),
          hasNextPage: _hasNextPage,
          totalPages: value.pageCount,
        );

        state = AsyncData(dto);

        return dto;
      case Failure e:
        state = AsyncError(e.exception, e.stackTrace);
        return Future.error(e.exception, e.stackTrace);
      case Canceled _:
        return ResponseDTO.empty();
    }
  }

  Future<void> loadMore() async {
    await _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    _page = 1;
    _hasNextPage = true;
    _data.clear();
    _uniqueMessageIds.clear();
    ref.invalidateSelf();
  }

  void tryUpdateMessage(ChatMessage? message) {
    if (message == null) return;

    var current = state.asData?.value;
    if (current == null) return;

    if (_uniqueMessageIds.contains(message.id)) return;

    _data.insert(0, message);
    _uniqueMessageIds.add(message.id);
    state = AsyncData(current.copyWith(data: _data.toList()));
  }

  void setFileLoading(String messageId, bool isLoading) {
    var current = state.asData?.value;
    if (current != null) {
      var messages = List<ChatMessage>.from(current.data);
      var index = messages.indexWhere((e) => e.id == messageId);
      if (index != -1) {
        messages[index] = messages[index].copyWith(isLoading: isLoading);

        state = AsyncData(current.copyWith(data: messages));
      }
    }
  }

  Future<List<ChatMessage>> setFileSize(List<ChatMessage> messages) async {
    final updatedMessages = List<ChatMessage>.from(messages);

    for (var i = 0; i < updatedMessages.length; i++) {
      final message = updatedMessages[i];

      if (message.type == MessageType.DOCUMENT) {
        final fileSize = await getFileSize(message.attachmentUrls.first);
        updatedMessages[i] = message.copyWith(fileSize: fileSize);
      }
    }

    return updatedMessages;
  }
}

final sendMessageProvider =
    NotifierProvider.autoDispose<SendMessageNotifier, bool>(
        SendMessageNotifier.new);

class SendMessageNotifier extends AutoDisposeNotifier<bool> {
  @override
  build() {
    return false;
  }

  void sendTextMessage(String chatId, String message) async {
    final _user = ref.read(loggedInUserProvider);

    ref.invalidate(chatListProvider);

    ref.read(webSocketProvider).emit("sendMessage", {
      "chatId": chatId,
      "message": message,
      "type": MessageType.TEXT.dbValue,
      "senderId": _user.id,
    });
  }

  void sendAttachmentMessage({
    required String chatId,
    required MessageType type,
    required List<String> attachments,
    required void Function() onError,
  }) async {
    final _user = ref.read(loggedInUserProvider);

    final confirmationId = await _uploadImages(attachments);

    if (confirmationId == null) {
      state = false;
      onError();
      return;
    }

    ref.read(webSocketProvider).emit("sendMessage", {
      "chatId": chatId,
      "message": "",
      "type": type.dbValue,
      "senderId": _user.id,
      "tempImgId": confirmationId,
    });
  }

  Future<String?> _uploadImages(List<String> attachments) async {
    bool uploadSuccess = true;

    final _sharedRepository = ref.read(sharedRepositoryProvider);
    final _appMessage = ref.read(appMessageProvider.notifier);

    final links = await _sharedRepository.getUploadLinks(
      attachments.length,
      UploadImageType.CHAT,
      attachments.map((e) => e.split("/").last).toList().join(','),
    );

    switch (links) {
      case Success(value: final data):
        await Future.wait(attachments.asMap().entries.map((attachment) async {
          final index = attachment.key;
          final path = attachment.value;
          final link = data.uri[index];

          try {
            await upload(
              uploadUrl: link,
              imageFile: File(path),
            );
          } catch (e) {
            uploadSuccess = false;
          }
        }));

        if (uploadSuccess) {
          return data.confirmationId;
        }

        return null;
      case Failure e:
        _appMessage.addException(exception: e.exception);
        return null;
      case Canceled _:
        return null;
    }
  }
}

final fileSizeProvider = AsyncNotifierProvider.family
    .autoDispose<FileSizeNotifier, int, String>(FileSizeNotifier.new);

class FileSizeNotifier extends AutoDisposeFamilyAsyncNotifier<int, String> {
  @override
  FutureOr<int> build(String arg) async {
    return await getFileSize(arg);
  }
}

final unreadCountProvider =
    AsyncNotifierProvider.autoDispose<UnreadCountNotifier, int>(
        UnreadCountNotifier.new);

class UnreadCountNotifier extends AutoDisposeAsyncNotifier<int> {
  @override
  FutureOr<int> build() async {
    return getUnreadCount();
  }

  Future<int> getUnreadCount() async {
    final _chatRepository = ref.read(chatRepositoryProvider);

    final res = await _chatRepository.getUnreadMessagesCount();

    switch (res) {
      case Success s:
        state = AsyncData(s.value);
        return s.value;
      case Failure e:
        return Future.error(e.exception, e.stackTrace);
      case Canceled _:
        return Future.error("");
    }
  }
}
