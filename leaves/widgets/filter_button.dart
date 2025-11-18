import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../router/routes.dart';
import '../../../shared/widgets/button.dart';
import '../../../translations/locale_keys.g.dart';
import '../providers/get_leaves_provider.dart';

class RequestLeaveButton extends ConsumerWidget {
  const RequestLeaveButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 24.w,
      ),
      child: Button(
        label: LocaleKeys.request_leaves.tr(),
        isDisabled: ref.watch(leaveOptionsStateProvider).isEmpty,
        onPressed: () {
          context.push(
            Routes.requestLeave,
          );
        },
      ),
    );
  }
}
