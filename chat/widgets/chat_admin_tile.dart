import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/entities/chat/chat_admin.dart';
import '../../../shared/widgets/padding.dart';

class ChatAdminTile extends StatelessWidget {
  final ChatAdmin admin;
  final VoidCallback onTap;

  const ChatAdminTile({
    required this.admin,
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
                    imageUrl: admin.avatar,
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
                  child: Text(
                    "${admin.firstName} ${admin.lastName}",
                    style: Theme.of(context).primaryTextTheme.displayMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
