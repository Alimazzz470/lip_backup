import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/toast.dart';
import '../../../translations/locale_keys.g.dart';
import '../providers/get_leaves_provider.dart';
import '../providers/request_leave_providers.dart';
import '../widgets/request_leave_body.dart';

class RequestLeavePage extends ConsumerWidget {
  const RequestLeavePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LocaleKeys.request_vacation.tr(),
          style: Theme.of(context).primaryTextTheme.displayLarge,
        ),
      ),
      body: SafeArea(
        child: RequestLeaveBody(
          onConfirm: () {
            final leave = ref.read(setLeaveDetailsProvider);
            final notifier = ref.read(requestLeavesProvider.notifier);
            notifier.requestLeave(
              type: leave.type,
              reason: leave.reason,
              startDate: leave.startDate!.toIso8601String(),
              endDate: leave.endDate!.toIso8601String(),
              onSuccess: () {
                ref.invalidate(leaveTypesProvider);
                ref.invalidate(leaveRequestProvider);
                ref.invalidate(leaveHistoryProvider);
                showSuccessSnackBar(
                  context,
                  message: LocaleKeys.success_leave_request.tr(),
                );
                context.pop();
              },
            );
          },
        ),
      ),
    );
  }
}
