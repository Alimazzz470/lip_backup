import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taxiapp_mobile/shared/widgets/padding.dart';
import '../../../shared/theme/app_colors.dart';

class SalaryTypeCard extends StatelessWidget {
  final String label;
  final String length;
  final int amount;
  final VoidCallback? onTap;

  const SalaryTypeCard({
    required this.label,
    required this.length,
    required this.amount,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5.r),
      child: Material(
        color: Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(5.r),
          onTap: onTap,
          child: Container(
            width: 220.w,
            padding: EdgeInsets.symmetric(
              horizontal: 15.w,
              vertical: 15.h,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 5.h,
                    ),
                    decoration: const BoxDecoration(
                      color: PRIMARY_COLOR,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      length,
                      style: Theme.of(context)
                          .primaryTextTheme
                          .displaySmall
                          ?.copyWith(color: Colors.white),
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "€ $amount",
                        style: Theme.of(context).primaryTextTheme.titleMedium,
                      ),
                    ),
                    const HorizontalSpace(space: 5),
                    Icon(
                      label == "Deduction" || label == "Penalty"
                          ? Icons.arrow_downward
                          : Icons.arrow_upward,
                      size: 30.w,
                      color: label == "Deduction" || label == "Penalty"
                          ? Colors.red
                          : Colors.green,
                    )
                  ],
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    "$label Received",
                    style: Theme.of(context)
                        .primaryTextTheme
                        .displayMedium
                        ?.copyWith(color: SECONDARY_TEXT_COLOR),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
