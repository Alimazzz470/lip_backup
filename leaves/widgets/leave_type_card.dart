import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/entities/leaves/leave_type.dart';
import '../../../translations/locale_keys.g.dart';

class LeaveTypeCard extends StatelessWidget {
  final LeaveType leaveType;

  const LeaveTypeCard({
    required this.leaveType,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120.w,
      height: 120.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "${leaveType.type.availableDays != null ? leaveType.availableDays : leaveType.appliedDays}",
            style: Theme.of(context).primaryTextTheme.titleMedium,
          ),
          Text(
            "${leaveType.type.name}\n${leaveType.type.name == "Overtime" ? LocaleKeys.available.tr() : LocaleKeys.leave.tr()}",
            style: Theme.of(context).primaryTextTheme.bodyLarge,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
