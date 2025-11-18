import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/dto/inspection.dart';
import '../../../router/routes.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/padding.dart';
import '../../../translations/locale_keys.g.dart';

class Inspection extends StatelessWidget {
  final String inspectionId;
  final String vehicleId;

  const Inspection({
    required this.inspectionId,
    required this.vehicleId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 20.w,
        vertical: 20.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: Row(
        children: [
          Flexible(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleKeys.car_inspection.tr(),
                  style: Theme.of(context).primaryTextTheme.displayMedium,
                ),
                const VerticalSpace(space: 10),
                Text(
                  LocaleKeys.car_inspection_description.tr(),
                  style:
                      Theme.of(context).primaryTextTheme.bodyMedium!.copyWith(
                            color: SECONDARY_TEXT_COLOR,
                          ),
                ),
              ],
            ),
          ),
          const HorizontalSpace(space: 18),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xff274690),
              borderRadius: BorderRadius.circular(3.r),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                splashColor: Colors.white.withOpacity(0.2),
                highlightColor: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(3.r),
                onTap: () {
                  context.push(
                    Routes.requestVehicleInspection,
                    extra: InspectionDto(
                      inspectionId: inspectionId,
                      vehicleId: vehicleId,
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 13.h,
                  ),
                  child: Text(
                    LocaleKeys.start.tr(),
                    style: Theme.of(context)
                        .primaryTextTheme
                        .bodyMedium!
                        .copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
