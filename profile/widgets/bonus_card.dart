import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/entities/bonus.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/padding.dart';
import '../../../shared/widgets/primary_card.dart';

class BonusCard extends StatelessWidget {
  final Bonus bonus;

  const BonusCard(
    this.bonus, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return PrimaryCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  DateFormat.yMMMMd().format(bonus.createdAt),
                  style: Theme.of(context).primaryTextTheme.displayMedium,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              const HorizontalSpace(),
            ],
          ),
          const VerticalSpace(),
          Container(
            height: 1.h,
            width: double.infinity,
            color: Colors.black,
          ),
          const VerticalSpace(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bonus.description,
                style: Theme.of(context).primaryTextTheme.bodyLarge!.copyWith(
                      color: SECONDARY_TEXT_COLOR,
                    ),
              ),
            ],
          ),
          const VerticalSpace(space: 30),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 6.h,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.r),
                border: Border.all(
                  color: Colors.black,
                ),
              ),
              child: Text(
                '€ ${bonus.amount.toStringAsFixed(2)}',
                style: Theme.of(context).primaryTextTheme.displaySmall,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
