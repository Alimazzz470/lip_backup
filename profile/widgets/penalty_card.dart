import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/entities/penalty.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/padding.dart';
import '../../../shared/widgets/primary_card.dart';
import '../../../translations/locale_keys.g.dart';

class PenaltyCard extends StatelessWidget {
  final Penalty penalty;
  final VoidCallback? onTap;

  const PenaltyCard(
    this.penalty, {
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: PrimaryCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    penalty.type,
                    style: Theme.of(context).primaryTextTheme.displayMedium,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                const HorizontalSpace(),
                Text(
                  DateFormat.yMMMMd().format(penalty.createdAt),
                  style: Theme.of(context).primaryTextTheme.bodyMedium,
                ),
              ],
            ),
            const VerticalSpace(),
            Container(
              height: 1.h,
              width: double.infinity,
              color: Colors.black,
            ),
            const VerticalSpace(),
            Text(
              penalty.description,
              style: Theme.of(context).primaryTextTheme.bodyLarge!.copyWith(
                    color: SECONDARY_TEXT_COLOR,
                  ),
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
                  '€ ${penalty.amount.toStringAsFixed(2)} ${LocaleKeys.fine.tr()}',
                  style: Theme.of(context).primaryTextTheme.displaySmall,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
