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
import '../profile_extensions.dart';
import '../providers/filter_providers.dart';

class Filter extends ConsumerStatefulWidget {
  const Filter({super.key});

  @override
  ConsumerState<Filter> createState() => _FilterState();
}

class _FilterState extends ConsumerState<Filter> {
  late final TextEditingController _startDateController;
  late final TextEditingController _endDateController;

  @override
  void initState() {
    super.initState();
    _startDateController = TextEditingController();
    _endDateController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final activeFilters = ref.read(modelFilterProvider);

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
      padding: EdgeInsets.symmetric(
        vertical: 30.h,
        horizontal: 24.w,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                LocaleKeys.filter.tr(),
                style: Theme.of(context).primaryTextTheme.displayMedium,
              ),
              GestureDetector(
                onTap: () {
                  ref.read(filterProvider.notifier).clearAllFilters();
                  ref.invalidate(modelFilterProvider);

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
            LocaleKeys.vacation_dates.tr(),
            style: Theme.of(context).primaryTextTheme.displaySmall,
          ),
          const VerticalSpace(space: 10),
          Row(
            children: [
              Expanded(
                child: PrimaryTextField(
                  controller: _startDateController,
                  hintText: LocaleKeys.start_date.tr(),
                  readOnly: true,
                  onTap: () async {
                    final startDate = await showDatePicker(
                      context: context,
                      initialDate: _startDateController.text.isNotEmpty
                          ? parseStringToDate(_startDateController.text).dateOnly
                          : DateTime.now().dateOnly,
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );

                    if (startDate != null) {
                      _startDateController.text = yyyyMMdd(startDate);
                      ref.read(modelFilterProvider.notifier).setStartDate(startDate);
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
                      initialDate: _startDateController.text.isNotEmpty
                          ? parseStringToDate(_startDateController.text).dateOnly
                          : DateTime.now().dateOnly,
                      firstDate: _startDateController.text.isNotEmpty
                          ? parseStringToDate(_startDateController.text)
                          : DateTime(1900),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );

                    if (endDate != null) {
                      _endDateController.text = yyyyMMdd(endDate);
                      ref.read(modelFilterProvider.notifier).setEndDate(endDate);
                    }
                  },
                ),
              ),
            ],
          ),
          const Spacer(),
          Consumer(
            builder: (_, ref, __) {
              final activeFilters = ref.watch(modelFilterProvider);

              return Button(
                label: LocaleKeys.confirm.tr(),
                isDisabled: activeFilters.activeFilters.isEmpty,
                onPressed: () {
                  ref.read(filterProvider.notifier).setFilters(activeFilters);
                  context.pop();
                },
              );
            },
          )
        ],
      ),
    );
  }
}
