import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/entities/time_tracking/driver_logs.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/utils/date_time.dart';
import '../../../shared/widgets/padding.dart';
import '../../../translations/locale_keys.g.dart';

class DrivingHourCard extends StatelessWidget {
  final DriverLog log;
  final VoidCallback onTap;

  const DrivingHourCard({
    required this.log,
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
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(5.r),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 20.w,
              vertical: 20.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatDateOrRelative(log.startTime!.dateOnly),
                  style: Theme.of(context).primaryTextTheme.displayLarge!.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const VerticalSpace(space: 15),
                Text(
                  "Worked Time: ${formatTime(log.workedTime)}",
                  style: Theme.of(context).primaryTextTheme.displayMedium!.copyWith(
                        color: SECONDARY_TEXT_COLOR,
                      ),
                ),
                const VerticalSpace(space: 5),
                Text(
                  "Break Time: ${formatTime(log.breaksTime)}",
                  style: Theme.of(context).primaryTextTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String formatTime(String time) {
    final parts = time.split(' ');
    final hours = int.parse(parts[0].substring(0, parts[0].length - 1));
    final minutes = int.parse(parts[1].substring(0, parts[1].length - 1));

    String formattedTime = '';

    if (hours > 0) {
      formattedTime += '$hours ${hours > 1 ? 'hours' : 'hour'}';
    }

    if (minutes > 0) {
      if (formattedTime.isNotEmpty) {
        formattedTime += ' ';
      }
      formattedTime += '$minutes ${minutes > 1 ? 'mins' : 'min'}';
    } else {
      if (formattedTime.isEmpty) {
        formattedTime = '0 mins';
      }
    }

    return formattedTime;
  }

  String formatDateOrRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    if (date.isAtSameMomentAs(today)) {
      return LocaleKeys.today.tr();
    } else if (date.isAtSameMomentAs(yesterday)) {
      return LocaleKeys.yesterday.tr();
    } else {
      return ddMMMyyyy(date);
    }
  }
}
