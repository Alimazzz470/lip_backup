import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/entities/vehicle/vehicle.dart';
import '../../../router/routes.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/padding.dart';
import '../../../translations/locale_keys.g.dart';

class VehicleDetailsCard extends StatelessWidget {
  final Vehicle vehicle;

  const VehicleDetailsCard({
    required this.vehicle,
    super.key,
  });

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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40.r,
                ),
                const HorizontalSpace(space: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${vehicle.brand} ${vehicle.model}',
                        style: Theme.of(context).primaryTextTheme.displayMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      VerticalSpace(space: 5.h),
                      Text(
                        vehicle.vehicleNumber,
                        style: Theme.of(context)
                            .primaryTextTheme
                            .displaySmall!
                            .copyWith(
                              color: SECONDARY_TEXT_COLOR,
                            ),
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Button(
            label: LocaleKeys.return_vehicle.tr(),
            width: 100.w,
            padding: EdgeInsets.symmetric(
              vertical: 10.h,
            ),
            textStyle: Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                  color: Colors.white,
                ),
            onPressed: () {
              context.push(
                Routes.returnVehicle,
                extra: vehicle.id,
              );
            },
          )
        ],
      ),
    );
  }
}
