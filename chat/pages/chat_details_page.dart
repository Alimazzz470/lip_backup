import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taxiapp_mobile/features/chat/providers/chat_provider.dart';
import '../../../core/entities/chat/chat_message.dart';
import '../../../core/services/image_helpers.dart';
import '../../../shared/providers/common_providers.dart';
import '../../../shared/providers/websocket_provider.dart';
import '../../../shared/widgets/bottom_modal.dart';
import '../../../shared/widgets/placeholders/empty_list_placeholder.dart';
import '../../../shared/widgets/toast.dart';
import '../../../translations/locale_keys.g.dart';
import '../chat_extensions.dart';
import '../providers/messages_provider.dart';
import '../widgets/chat_bubble.dart';

class ChatDetailsPage extends ConsumerStatefulWidget {
  final String chatId;

  const ChatDetailsPage({
    required this.chatId,
    super.key,
  });

  @override
  ConsumerState<ChatDetailsPage> createState() => _ChatDetailsPageState();
}

class _ChatDetailsPageState extends ConsumerState<ChatDetailsPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _updateUnReadMessages();
  }

  @override
  void deactivate() {
    _updateUnReadMessages();
    super.deactivate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      // Refresh chat messages
      // ref.read(chatMessagesProvider(widget.chat.id).notifier).refresh();
    }
  }

  void _updateUnReadMessages() {
    final user = ref.read(loggedInUserProvider);
    ref.read(webSocketProvider).emit("readMessage", {
      "chatId": widget.chatId,
      "userId": user.id,
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(loggedInUserProvider);
    final chatDetails = ref.watch(chatDetailsProvider(widget.chatId));

    return Scaffold(
      appBar: AppBar(
          title: chatDetails.when(
              data: (chatDetails) => Text(
                    user.id == chatDetails.adminId
                        ? chatDetails.userName
                        : chatDetails.adminName,
                    style: Theme.of(context).primaryTextTheme.displayLarge,
                  ),
              error: ((error, stackTrace) => Container()),
              loading: () => Container())),
      body: ref.watch(chatMessagesProvider(widget.chatId)).when(
        data: (messages) {
          return Chat(
            onEndReached:
                ref.read(chatMessagesProvider(widget.chatId).notifier).loadMore,
            isLastPage: !messages.hasNextPage,
            messages: messages.data.expand((e) => _mapMessage(e)).toList(),
            onSendPressed: (message) {
              ref
                  .read(sendMessageProvider.notifier)
                  .sendTextMessage(widget.chatId, message.text);
            },
            onMessageTap: (context, message) async {
              if (message is types.FileMessage) {
                _downloadFileAndOpen(
                  messageId: message.id,
                  downloadUri: message.uri,
                  fileName: message.name,
                );
              }
            },
            onAttachmentPressed: _handleAttachmentPressed,
            user: types.User(
              id: user.id,
            ),
            theme: DefaultChatTheme(
              inputBackgroundColor: Colors.white,
              inputTextColor: Colors.black,
              inputTextDecoration: InputDecoration(
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black,
                    width: 1,
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black,
                    width: 1.5,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 15.h,
                ),
              ),
              messageInsetsHorizontal: 15.w,
              messageInsetsVertical: 10.h,
            ),
            dateIsUtc: true,
            bubbleBuilder: (
              child, {
              required message,
              required nextMessageInGroup,
            }) {
              return ChatBubble(
                isSender: message.author.id == user.id,
                messageDT:
                    DateTime.fromMillisecondsSinceEpoch(message.createdAt!),
                isLastGroupMessage: !nextMessageInGroup,
                child: child,
              );
            },
            imageMessageBuilder: (
              imageMessage, {
              required int messageWidth,
            }) {
              return ImageChatBubble(imageMessage);
            },
            fileMessageBuilder: (
              fileMessage, {
              required int messageWidth,
            }) {
              return FileChatBubble(fileMessage);
            },
          );
        },
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (e, s) {
          return EmptyListPlaceholder(error);
        },
      ),
    );
  }

  List<types.Message> _mapMessage(ChatMessage message) {
    return switch (message.type) {
      MessageType.TEXT => [
          types.TextMessage(
            id: message.id,
            text: message.message,
            author: types.User(id: message.senderId),
            createdAt: message.messageDateTime.millisecondsSinceEpoch,
          ),
        ],
      MessageType.IMAGE => message.attachmentUrls
          .map((imageUrl) => types.ImageMessage(
                id: message.id,
                author: types.User(id: message.senderId),
                name: message.message,
                size: 0,
                uri: imageUrl,
                createdAt: message.messageDateTime.millisecondsSinceEpoch,
              ))
          .toList(),
      MessageType.DOCUMENT => message.attachmentUrls
          .map((fileUrl) => types.FileMessage(
                id: message.id,
                author: types.User(id: message.senderId),
                name: fileUrl.split('/').last,
                size: message.fileSize,
                uri: fileUrl,
                createdAt: message.messageDateTime.millisecondsSinceEpoch,
                isLoading: message.isLoading,
              ))
          .toList(),
    };
  }

  void _handleAttachmentPressed() {
    showBottomModal(
      context: context,
      height: 180.w,
      child: ListView(
        children: [
          ListTile(
            onTap: () {
              Navigator.pop(context);
              _handleImageSelection();
            },
            title: Text(LocaleKeys.photo.tr()),
            leading: const Icon(Icons.image),
          ),
          ListTile(
            onTap: () {
              Navigator.pop(context);
              _handleFileSelection();
            },
            title: Text(LocaleKeys.file.tr()),
            leading: const Icon(Icons.file_copy),
          ),
        ],
      ),
    );
  }

  void _handleFileSelection() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx'],
    );

    if (result != null && result.files.single.path != null) {
      ref.read(sendMessageProvider.notifier).sendAttachmentMessage(
          chatId: widget.chatId,
          type: MessageType.DOCUMENT,
          attachments: [result.files.single.path!],
          onError: () {
            showErrorSnackBar(
              context,
              messageText: LocaleKeys.error_failed_to_upload_images.tr(),
            );
          });
    }
  }

  void _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );
    if (!mounted) return;

    if (result != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(LocaleKeys.send_image.tr()),
            content: Image.file(
              File(result.path),
              fit: BoxFit.cover,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(LocaleKeys.cancel.tr()),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ref.read(sendMessageProvider.notifier).sendAttachmentMessage(
                        chatId: widget.chatId,
                        type: MessageType.IMAGE,
                        attachments: [result.path],
                        onError: () {
                          showErrorSnackBar(
                            context,
                            messageText:
                                LocaleKeys.error_failed_to_upload_images.tr(),
                          );
                        },
                      );
                },
                child: Text(LocaleKeys.send.tr()),
              ),
            ],
          );
        },
      );
    }
  }

  void _downloadFileAndOpen({
    required String messageId,
    required String downloadUri,
    required String fileName,
  }) async {
    final notifier = ref.read(chatMessagesProvider(widget.chatId).notifier);

    notifier.setFileLoading(messageId, true);

    final localPath = await downloadFile(
      downloadUri: downloadUri,
      fileName: fileName,
    );

    notifier.setFileLoading(messageId, false);

    // TODO: Check why a folder is created
    openFile(localPath);
  }
}
