import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/entities/leaves/leave.dart';
import '../../../shared/widgets/primary_card.dart';
import '../../../translations/locale_keys.g.dart';
import '../leaves_extensions.dart';

class LeaveCard extends StatelessWidget {
  final Leave leave;
  final double? width;

  const LeaveCard({
    required this.leave,
    this.width,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return PrimaryCard(
      width: width ?? double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${leave.type.name} ${LocaleKeys.leave.tr()}",
                  style: Theme.of(context).primaryTextTheme.displaySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  leave.date,
                  style: Theme.of(context).primaryTextTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 13.w,
              vertical: 9.h,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.r),
              border: Border.all(
                color: leave.status.color,
                width: 1.w,
              ),
            ),
            child: Text(
              leave.status.name,
              style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                    color: leave.status.color,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
