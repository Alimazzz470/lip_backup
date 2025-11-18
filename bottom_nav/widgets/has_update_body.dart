import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:restart_app/restart_app.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/padding.dart';
import '../../../translations/locale_keys.g.dart';

class HasUpdateBody extends StatelessWidget {
  const HasUpdateBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 30.h,
        horizontal: 24.w,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaleKeys.new_update_available.tr(),
            style: Theme.of(context).primaryTextTheme.titleMedium,
          ),
          const VerticalSpace(),
          Text(
            LocaleKeys.new_update_available_description.tr(),
            style: Theme.of(context).primaryTextTheme.displayMedium!.copyWith(
                  color: SECONDARY_TEXT_COLOR,
                ),
          ),
          const Spacer(),
          Button(
            label: LocaleKeys.restart.tr(),
            onPressed: () {
              Restart.restartApp();
            },
          ),
        ],
      ),
    );
  }
}
