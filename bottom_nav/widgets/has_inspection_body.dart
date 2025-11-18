import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/dto/inspection.dart';
import '../../../router/routes.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/padding.dart';
import '../../../translations/locale_keys.g.dart';

class HasInspectionBody extends StatelessWidget {
  final String inspectionId;
  final String vehicleId;

  const HasInspectionBody(
    this.inspectionId,
    this.vehicleId, {
    super.key,
  });

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
            LocaleKeys.monthly_inspection.tr(),
            style: Theme.of(context).primaryTextTheme.titleMedium,
          ),
          const VerticalSpace(),
          Text(
            LocaleKeys.monthly_inspection_description.tr(),
            style: Theme.of(context).primaryTextTheme.displayMedium!.copyWith(
                  color: SECONDARY_TEXT_COLOR,
                ),
          ),
          const Spacer(),
          Button(
            label: LocaleKeys.start_inspection.tr(),
            onPressed: () {
              context.go(
                Routes.monthlyInspection,
                extra: InspectionDto(
                  inspectionId: inspectionId,
                  vehicleId: vehicleId,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
