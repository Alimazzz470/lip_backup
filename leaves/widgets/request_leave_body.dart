import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/dto/option.dart';
import '../../../shared/utils/date_time.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/padding.dart';
import '../../../shared/widgets/primary_dropdown.dart';
import '../../../shared/widgets/primary_text_field.dart';
import '../../../translations/locale_keys.g.dart';
import '../providers/get_leaves_provider.dart';
import '../providers/request_leave_providers.dart';

class RequestLeaveBody extends ConsumerStatefulWidget {
  final VoidCallback onConfirm;

  const RequestLeaveBody({
    required this.onConfirm,
    super.key,
  });

  @override
  ConsumerState<RequestLeaveBody> createState() => _LeaveBottomSheetBodyState();
}

class _LeaveBottomSheetBodyState extends ConsumerState<RequestLeaveBody> {
  late final TextEditingController _startDateController;
  late final TextEditingController _endDateController;

  @override
  void initState() {
    super.initState();
    _startDateController = TextEditingController();
    _endDateController = TextEditingController();
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final options = ref.watch(leaveOptionsStateProvider);
    final isLoading = ref.watch(requestLeavesProvider);

    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Padding(
            padding: EdgeInsets.symmetric(
              vertical: 30.h,
              horizontal: 24.w,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const VerticalSpace(space: 30),
                PrimaryDropdown(
                  hint: LocaleKeys.holiday_type.tr(),
                  options: options.map((e) {
                    return Option(
                      label: e.label,
                      value: e.value,
                    );
                  }).toList(),
                  onChanged: (type) {
                    ref.read(setLeaveDetailsProvider.notifier).setType(type!);
                  },
                ),
                const VerticalSpace(space: 30),
                Text(
                  LocaleKeys.vacation_dates.tr(),
                  style: Theme.of(context).primaryTextTheme.displaySmall,
                ),
                const VerticalSpace(space: 10),
                Consumer(
                  builder: (_, ref, __) {
                    final requestLeaves = ref.watch(setLeaveDetailsProvider);

                    final startDate = requestLeaves.startDate;
                    final endDate = requestLeaves.endDate;

                    _startDateController.value = TextEditingValue(
                      text: startDate != null ? yyyyMMdd(startDate) : '',
                    );
                    _endDateController.value = TextEditingValue(
                      text: endDate != null ? yyyyMMdd(endDate) : '',
                    );
                    return Row(
                      children: [
                        Expanded(
                          child: PrimaryTextField(
                            controller: _startDateController,
                            hintText: LocaleKeys.start_date.tr(),
                            readOnly: true,
                            onTap: () async {
                              final startDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now()
                                    .add(const Duration(days: 365)),
                              );

                              if (startDate != null) {
                                ref
                                    .read(setLeaveDetailsProvider.notifier)
                                    .setStartDate(startDate);
                              }
                            },
                          ),
                        ),
                        const HorizontalSpace(space: 20),
                        Expanded(
                          child: PrimaryTextField(
                            controller: _endDateController,
                            hintText: LocaleKeys.end_date.tr(),
                            readOnly: true,
                            onTap: () async {
                              final endDate = await showDatePicker(
                                context: context,
                                initialDate: startDate ?? DateTime.now(),
                                firstDate: startDate ?? DateTime.now(),
                                lastDate: DateTime.now()
                                    .add(const Duration(days: 365)),
                              );

                              if (endDate != null) {
                                ref
                                    .read(setLeaveDetailsProvider.notifier)
                                    .setEndDate(endDate);
                              }
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const VerticalSpace(space: 30),
                PrimaryTextField(
                  label: LocaleKeys.reason.tr(),
                  maxLines: 3,
                  onChanged: (reason) {
                    ref
                        .read(setLeaveDetailsProvider.notifier)
                        .setReason(reason);
                  },
                ),
                const Spacer(),
                Button(
                  label: LocaleKeys.confirm.tr(),
                  onPressed: widget.onConfirm,
                )
              ],
            ),
          );
  }
}
