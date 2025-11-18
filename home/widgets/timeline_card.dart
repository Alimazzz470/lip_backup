import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../shared/theme/app_colors.dart';
import '../dto/today_log.dart';

class TimelineCard extends StatelessWidget {
  final int index;
  final int length;
  final TodayLogDto timeline;

  const TimelineCard({
    super.key,
    required this.timeline,
    required this.index,
    required this.length,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(
        bottom: 15.h,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 20.w,
        vertical: 20.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: Column(
        children: [
          if (timeline.startTime != null && index == 0) ...[
            _TimeText(
              label: "Work Initiated",
              time: timeline.startTimeString,
            ),
          ],
          if (timeline.endTime != null && index == length - 1) ...[
            _TimeText(
              label: "Work Completed",
              time: timeline.endTimeString,
            ),
          ],
          if (timeline.breakStarted != null) ...[
            _TimeText(
              label: "Break Started",
              time: timeline.breakStartedString,
            ),
          ],
          if (timeline.breakEnded != null) ...[
            Padding(
              padding: timeline.breakStarted != null ? EdgeInsets.only(top: 10.h) : EdgeInsets.zero,
              child: _TimeText(
                label: "Break Ended",
                time: timeline.breakEndedString,
              ),
            ),
          ],
          if (timeline.startTime != null && timeline.endTime == null && index != 0) ...[
            _TimeText(
              label: "Work Started",
              time: timeline.startTimeString,
            ),
          ],
        ],
      ),
    );
  }
}

class _TimeText extends StatelessWidget {
  final String label;
  final String time;

  const _TimeText({
    Key? key,
    required this.label,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).primaryTextTheme.displayLarge,
        ),
        Text(
          time,
          style: Theme.of(context).primaryTextTheme.displayMedium!.copyWith(
                color: SECONDARY_TEXT_COLOR,
              ),
        ),
      ],
    );
  }
}
