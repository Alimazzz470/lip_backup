import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/padding.dart';

class VehicleCard extends StatelessWidget {
  final String plate;
  final String type;
  final bool isAvailable;
  final VoidCallback? onTap;

  const VehicleCard({
    required this.plate,
    required this.type,
    required this.isAvailable,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 15.w,
          vertical: 15.h,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.r),
          border: Border.all(
            color: isAvailable ? SUCCESS_COLOR : ERROR_COLOR,
            width: 1.5.w,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              plate,
              style: Theme.of(context).primaryTextTheme.displayMedium!.copyWith(
                    color: isAvailable ? SUCCESS_COLOR : ERROR_COLOR,
                  ),
            ),
            const VerticalSpace(space: 30),
            Text(
              type,
              style: Theme.of(context).primaryTextTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
