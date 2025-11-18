import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/utils/date_time.dart';
import '../providers/messages_provider.dart';

const _kBorderRadius = Radius.circular(12);

class ChatBubble extends StatelessWidget {
  final bool isSender;
  final bool isLastGroupMessage;
  final Widget child;
  final DateTime messageDT;

  const ChatBubble({
    required this.isSender,
    required this.isLastGroupMessage,
    required this.child,
    required this.messageDT,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        const Padding(padding: EdgeInsets.only(top: 5)),
        DecoratedBox(
          decoration: BoxDecoration(
            color: isSender ? PRIMARY_COLOR : Colors.grey[200],
            borderRadius: const BorderRadius.all(_kBorderRadius),
          ),
          child: child,
        ),
        if (isLastGroupMessage)
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              formatTime(messageDT),
              style: Theme.of(context).textTheme.labelMedium,
            ),
          )
      ],
    );
  }
}

class FileChatBubble extends ConsumerWidget {
  final types.FileMessage fileMessage;

  const FileChatBubble(
    this.fileMessage, {
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fileSize = ref.watch(fileSizeProvider(fileMessage.uri));

    if (fileSize.isLoading) {
      return SizedBox(
        width: 80.w,
        height: 80.w,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return FileMessage(
      message: types.FileMessage(
        id: fileMessage.id,
        author: fileMessage.author,
        name: fileMessage.name,
        size: fileSize.maybeWhen(
          orElse: () => 0,
          data: (size) => size,
        ),
        uri: fileMessage.uri,
        createdAt: fileMessage.createdAt,
        isLoading: fileMessage.isLoading,
      ),
    );
  }
}

class ImageChatBubble extends StatelessWidget {
  final types.ImageMessage imageMessage;

  const ImageChatBubble(
    this.imageMessage, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: CachedNetworkImage(
        imageUrl: imageMessage.uri,
        progressIndicatorBuilder: (_, __, d) => SizedBox(
          width: 120.w,
          height: 120.w,
          child: Center(
            child: CircularProgressIndicator(value: d.progress),
          ),
        ),
        errorWidget: (_, __, ___) => const Icon(Icons.error),
      ),
    );
  }
}
