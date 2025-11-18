import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/utils/date_time.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/padding.dart';
import '../../../shared/widgets/primary_text_field.dart';
import '../../../translations/locale_keys.g.dart';
import '../home_extensions.dart';
import '../providers/filter_logs_providers.dart';

class WorkingHoursFilter extends ConsumerStatefulWidget {
  const WorkingHoursFilter({super.key});

  @override
  ConsumerState<WorkingHoursFilter> createState() => _WorkingHoursFilterState();
}

class _WorkingHoursFilterState extends ConsumerState<WorkingHoursFilter> {
  late final TextEditingController _startDateController;
  late final TextEditingController _endDateController;

  @override
  void initState() {
    super.initState();

    _startDateController = TextEditingController();
    _endDateController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final activeFilters = ref.read(modelLogFilterProvider);

      if (activeFilters.startDate != null) {
        _startDateController.text = yyyyMMdd(activeFilters.startDate!);
      }

      if (activeFilters.endDate != null) {
        _endDateController.text = yyyyMMdd(activeFilters.endDate!);
      }
    });
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 30.h,
        left: 24.w,
        right: 24.w,
        bottom: 30.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                LocaleKeys.working_hours_filter.tr(),
                style: Theme.of(context).primaryTextTheme.displayMedium,
              ),
              GestureDetector(
                onTap: () {
                  ref.read(logFilterProvider.notifier).clearAllFilters();
                  ref.invalidate(modelLogFilterProvider);

                  _startDateController.clear();
                  _endDateController.clear();

                  context.pop();
                },
                child: Text(
                  LocaleKeys.clear_filter.tr(),
                  style: Theme.of(context).primaryTextTheme.displayMedium,
                ),
              ),
            ],
          ),
          const VerticalSpace(space: 30),
          Text(
            "Date",
            style: Theme.of(context).primaryTextTheme.displaySmall,
          ),
          const VerticalSpace(space: 10),
          Row(
            children: [
              Flexible(
                child: PrimaryTextField(
                  controller: _startDateController,
                  hintText: LocaleKeys.start_date.tr(),
                  readOnly: true,
                  onTap: () async {
                    final startDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );

                    if (startDate != null) {
                      _startDateController.text = yyyyMMdd(startDate);
                      ref.read(modelLogFilterProvider.notifier).setStartDate(startDate);
                    }
                  },
                ),
              ),
              const HorizontalSpace(space: 20),
              Flexible(
                child: PrimaryTextField(
                  controller: _endDateController,
                  hintText: LocaleKeys.end_date.tr(),
                  readOnly: true,
                  onTap: () async {
                    final endDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );

                    if (endDate != null) {
                      _endDateController.text = yyyyMMdd(endDate);
                      ref.read(modelLogFilterProvider.notifier).setEndDate(endDate);
                    }
                  },
                ),
              ),
            ],
          ),
          const Spacer(),
          Consumer(
            builder: (context, ref, child) {
              final activeFilters = ref.watch(modelLogFilterProvider);

              return Button(
                label: LocaleKeys.confirm.tr(),
                isDisabled: activeFilters.activeFilters.isEmpty,
                onPressed: () {
                  ref.read(logFilterProvider.notifier).setFilters(activeFilters);
                  context.pop();
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
