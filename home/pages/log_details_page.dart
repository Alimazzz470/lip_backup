import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/entities/time_tracking/driver_logs.dart';
import '../../../shared/utils/date_time.dart';
import '../../../shared/widgets/padding.dart';
import '../providers/time_logs_providers.dart';
import '../widgets/timeline_card.dart';

class LogDetailsPage extends StatelessWidget {
  final DriverLog log;

  const LogDetailsPage({
    required this.log,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          ddMMMyyyy(log.startTime!),
          style: Theme.of(context).primaryTextTheme.displayLarge,
        ),
      ),
      body: Consumer(
        builder: (_, ref, __) {
          final timeline = ref.watch(timelineProvider(log));

          return ListView.separated(
            itemCount: timeline.length,
            padding: EdgeInsets.symmetric(
              horizontal: 24.w,
              vertical: 40.h,
            ),
            itemBuilder: (context, index) {
              return TimelineCard(
                index: index,
                length: timeline.length,
                timeline: timeline[index],
              );
            },
            separatorBuilder: (context, index) {
              return const VerticalSpace(space: 1);
            },
          );
        },
      ),
    );
  }
}
