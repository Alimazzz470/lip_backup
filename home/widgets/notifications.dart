import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:taxiapp_mobile/features/home/providers/get_notifications_providers.dart';
import 'package:taxiapp_mobile/network/models/notification_model.dart';
import '../../../core/dto/inspection.dart';
import '../../../core/entities/notifications/notifications.dart';
import '../../../router/routes.dart';
import '../../../shared/utils/notification_formatter.dart';

class NotificationWidget extends ConsumerWidget {
  final Notifications notification;

  const NotificationWidget({super.key, required this.notification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        ref
            .read(notificationsProvider.notifier)
            .markAsRead(id: notification.id);
        // navigate to the correct page based on the type using case statement
        var type = parseNotificationType(notification.type);
        switch (type) {
          case NotificationType.vehicleInspection:
            context.push(
              Routes.requestVehicleInspection,
              extra: InspectionDto(
                inspectionId:
                    notification.meta.description.arguments['inspectionId'],
                vehicleId: notification.meta.description.arguments['vehicleId'],
              ),
            );
            break;
          case NotificationType.leaveCreated:
            context.go(
              Routes.leaves,
              extra: notification.meta.actionData['leaveId'],
            );
            break;
          case NotificationType.leaveUpdated:
            context.go(
              Routes.leaves,
              extra: notification.meta.actionData['leaveId'],
            );
            break;
          case NotificationType.advanceReceived ||
                NotificationType.advanceUpdated:
            context.push(Routes.advanceDetailsUri(
                notification.meta.actionData['advanceId']));
            break;
          case NotificationType.deductionReceived:
            notification.meta.description.text == "PENALTY"
                ? context.push(Routes.deductionDetailsUri(
                    notification.meta.actionData['deductionId']))
                : context.push(Routes.penaltyDetailsUri(
                    notification.meta.actionData['deductionId']));
            break;
          case NotificationType.bonusReceived:
            context.push(Routes.bonusDetailsUri(
                notification.meta.actionData['bonusId']));
            break;
          case NotificationType.taskCreated || NotificationType.taskUpdated:
            context.push(
                Routes.taskDetailsUri(notification.meta.actionData['taskId']));
            break;
          default:
            break;
        }
      },
      child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 24.w,
            vertical: 20.h,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formatType(notifications: notification),
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                formatDescription(notifications: notification),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.black87,
                    ),
              ),
            ],
          )),
    );
  }
}
