import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/helpers/app_data.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/padding.dart';
import '../../../shared/widgets/primary_dropdown.dart';
import '../../../shared/widgets/toast.dart';
import '../../../translations/locale_keys.g.dart';
import '../providers/download_payslip_provider.dart';

class DownloadPayroll extends ConsumerWidget {
  const DownloadPayroll({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(downloadPayslipProvider);
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 24.w,
              vertical: 40.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleKeys.download_payslip.tr(),
                  style: Theme.of(context).primaryTextTheme.displayMedium,
                ),
                const VerticalSpace(space: 40),
                PrimaryDropdown(
                  hint: LocaleKeys.select_month.tr(),
                  options: monthList,
                  onChanged: (month) {
                    if (month == null) return;
                    ref.read(selectMonthYearProvider.notifier).setMonth(month);
                  },
                ),
                const VerticalSpace(),
                PrimaryDropdown(
                  hint: LocaleKeys.select_year.tr(),
                  options: yearList,
                  onChanged: (year) {
                    if (year == null) return;
                    ref.read(selectMonthYearProvider.notifier).setYear(year);
                  },
                ),
                const Spacer(),
                Consumer(
                  builder: (_, ref, __) {
                    final monthYear = ref.watch(selectMonthYearProvider);
                    return Button(
                      label: LocaleKeys.download.tr(),
                      isDisabled: monthYear.isDisabled,
                      onPressed: () {
                        ref.read(downloadPayslipProvider.notifier).download(
                          onSuccess: (data) {
                            context.pop();
                            showSuccessSnackBar(
                              context,
                              message: LocaleKeys.success_payslip_downloaded.tr(),
                            );
                          },
                          onError: (e) {
                            context.pop();
                            showErrorSnackBar(context, message: e);
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
  }
}
