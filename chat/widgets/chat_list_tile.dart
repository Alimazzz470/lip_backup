import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/entities/chat/chat_details.dart';
import '../../../shared/helpers/app_assets.dart';
import '../../../shared/widgets/padding.dart';
import '../chat_extensions.dart';

class ChatListTile extends StatelessWidget {
  final ChatDetails chat;
  final bool isUserAdmin;
  final int unreadCount;
  final VoidCallback onTap;

  const ChatListTile({
    required this.chat,
    required this.isUserAdmin,
    required this.unreadCount,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(5.r),
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(10.w),
            child: Row(
              children: [
                ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: isUserAdmin
                        ? chat.userAvatar ?? USER_PLACEHOLDER_IMAGE
                        : chat.adminAvatar ?? USER_PLACEHOLDER_IMAGE,
                    fit: BoxFit.fitHeight,
                    width: 60.r,
                    height: 60.r,
                    progressIndicatorBuilder: (_, __, d) => Center(
                      child: CircularProgressIndicator(value: d.progress),
                    ),
                    errorWidget: (_, __, ___) => const Icon(Icons.error),
                  ),
                ),
                const HorizontalSpace(),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isUserAdmin ? chat.userName : chat.adminName,
                        style: Theme.of(context).primaryTextTheme.displayMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const VerticalSpace(space: 5),
                      switch (chat.type) {
                        MessageType.TEXT => Text(
                            chat.lastMessage ?? "",
                            style: Theme.of(context).primaryTextTheme.labelMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        MessageType.IMAGE => Row(
                            children: [
                              Icon(
                                Icons.camera_alt_rounded,
                                size: 20.w,
                              ),
                              const HorizontalSpace(space: 5),
                              Text(
                                chat.type.name,
                                style: Theme.of(context).primaryTextTheme.labelMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        MessageType.DOCUMENT => Row(
                            children: [
                              Icon(
                                Icons.insert_drive_file_rounded,
                                size: 20.w,
                              ),
                              const HorizontalSpace(space: 5),
                              Text(
                                chat.type.name,
                                style: Theme.of(context).primaryTextTheme.labelMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                      },
                    ],
                  ),
                ),
                const HorizontalSpace(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      chat.time,
                      style: Theme.of(context).primaryTextTheme.labelMedium,
                    ),
                    if (unreadCount > 0) ...[
                      const VerticalSpace(space: 5),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 7.w,
                          vertical: 2.h,
                        ),
                        child: Text(
                          "$unreadCount",
                          style: Theme.of(context).primaryTextTheme.labelMedium!.copyWith(
                                color: Colors.white,
                              ),
                        ),
                      ),
                    ]
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
