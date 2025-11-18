import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/entities/advance.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/padding.dart';
import '../../../shared/widgets/primary_card.dart';
import '../../../translations/locale_keys.g.dart';
import '../profile_extensions.dart';

class AdvanceCard extends StatelessWidget {
  final Advance advance;

  const AdvanceCard(
    this.advance, {
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
                  DateFormat.yMMMMd().format(advance.createdAt),
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
                "${LocaleKeys.reason.tr()}:",
                style: Theme.of(context).primaryTextTheme.bodyLarge!.copyWith(
                      color: SECONDARY_TEXT_COLOR,
                    ),
              ),
              Text(
                advance.description,
                style: Theme.of(context).primaryTextTheme.bodyLarge!.copyWith(
                      color: SECONDARY_TEXT_COLOR,
                    ),
              ),
            ],
          ),
          if (advance.status == AdvanceStatus.REJECTED &&
              advance.rejectReason != null &&
              advance.rejectReason!.isNotEmpty) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const VerticalSpace(space: 30),
                Text(
                  "${LocaleKeys.reason_for_rejection.tr()}:",
                  style: Theme.of(context).primaryTextTheme.bodyLarge!.copyWith(
                        color: SECONDARY_TEXT_COLOR,
                      ),
                ),
                Text(
                  advance.rejectReason ?? '',
                  style: Theme.of(context).primaryTextTheme.bodyLarge!.copyWith(
                        color: SECONDARY_TEXT_COLOR,
                      ),
                ),
              ],
            ),
          ],
          const VerticalSpace(space: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: 6.h,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.r),
                  border: Border.all(
                    color: advance.status.color,
                  ),
                ),
                child: Text(
                  advance.status.name,
                  style:
                      Theme.of(context).primaryTextTheme.displaySmall!.copyWith(
                            color: advance.status.color,
                          ),
                ),
              ),
              Container(
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
                  '€ ${advance.amount.toStringAsFixed(2)}',
                  style: Theme.of(context).primaryTextTheme.displaySmall,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
