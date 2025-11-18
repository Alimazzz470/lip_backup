import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:taxiapp_mobile/features/profile/providers/request_advance_provider.dart';
import 'package:taxiapp_mobile/shared/helpers/app_data.dart';
import 'package:taxiapp_mobile/shared/widgets/button.dart';
import 'package:taxiapp_mobile/shared/widgets/padding.dart';
import 'package:taxiapp_mobile/shared/widgets/primary_text_field.dart';
import 'package:taxiapp_mobile/shared/widgets/toast.dart';
import 'package:taxiapp_mobile/translations/locale_keys.g.dart';

class RequestAdvancePage extends ConsumerWidget {
  const RequestAdvancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(requestAdvanceProvider);
    return Scaffold(
        appBar: AppBar(
          title: Text(
            LocaleKeys.request_advance.tr(),
            style: Theme.of(context).primaryTextTheme.displayLarge,
          ),
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                  vertical: 40.h,
                ),
                child: CustomScrollView(
                  slivers: [
                    SliverFillRemaining(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PrimaryTextField(
                            label: LocaleKeys.enter_amount.tr(),
                            onChanged: (v) {
                              ref.read(amountProvider.notifier)(v);
                            },
                          ),
                          const VerticalSpace(space: 30),
                          PrimaryTextField(
                            label: LocaleKeys.reason.tr(),
                            maxLines: 5,
                            onChanged: (v) {
                              ref.read(reasonProvider.notifier)(v);
                            },
                          ),
                          const VerticalSpace(space: 30),
                          Text(
                            LocaleKeys.payable_time.tr(),
                            style:
                                Theme.of(context).primaryTextTheme.displaySmall,
                          ),
                          const VerticalSpace(space: 15),
                          Wrap(
                            children: payableMonthList.map((e) {
                              return Consumer(
                                builder: (_, ref, __) {
                                  final selectedTime =
                                      ref.watch(payableTimeProvider);
                                  final isSelected = selectedTime ==
                                      payableMonthList.indexOf(e) + 1;

                                  return Padding(
                                    padding: EdgeInsets.only(
                                      right: 10.w,
                                    ),
                                    child: ChoiceChip(
                                      label: Text(e.label),
                                      selected: isSelected,
                                      onSelected: (_) {
                                        int index =
                                            payableMonthList.indexOf(e) + 1;
                                        ref.read(payableTimeProvider.notifier)(
                                            index);
                                      },
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          ),
                          const Spacer(),
                          Consumer(
                            builder: (_, ref, __) {
                              final amount = ref.watch(amountProvider);
                              final reason = ref.watch(reasonProvider);
                              final payableTime =
                                  ref.watch(payableTimeProvider);

                              return Button(
                                label: LocaleKeys.confirm.tr(),
                                isDisabled:
                                    _isDisabled(amount, reason, payableTime),
                                onPressed: () {
                                  ref
                                      .read(requestAdvanceProvider.notifier)
                                      .requestAdvance(
                                        amount: amount!,
                                        description: reason!,
                                        installmentPeriod:
                                            payableTime.toString(),
                                        onSuccess: () {
                                          context.pop();
                                          showSuccessSnackBar(
                                            context,
                                            message: LocaleKeys
                                                .success_advance_request
                                                .tr(),
                                          );
                                        },
                                      );
                                },
                              );
                            },
                          )
                        ],
                      ),
                    )
                  ],
                )));
  }

  bool _isDisabled(String? amount, String? reason, int? payableTime) {
    return amount == null ||
        amount.isEmpty ||
        reason == null ||
        reason.isEmpty ||
        payableTime == null;
  }
}
