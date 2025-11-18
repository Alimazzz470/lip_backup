import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../router/routes.dart';
import '../../../shared/widgets/bottom_modal.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/no_data_placeholder.dart';
import '../../../shared/widgets/padding.dart';
import '../../../shared/widgets/placeholders/empty_list_placeholder.dart';
import '../../../translations/locale_keys.g.dart';
import '../home_extensions.dart';
import '../providers/filter_logs_providers.dart';
import '../providers/time_logs_providers.dart';
import '../widgets/driving_hours_card.dart';
import '../widgets/working_hours_filter.dart';

class DrivingHoursPage extends ConsumerStatefulWidget {
  const DrivingHoursPage({super.key});

  @override
  ConsumerState<DrivingHoursPage> createState() => _DrivingHoursPageState();
}

class _DrivingHoursPageState extends ConsumerState<DrivingHoursPage> {
  late final ScrollController _scrollController;
  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(_loadMoreListener);
    super.initState();
  }

  void _loadMoreListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      ref.read(timeLogsProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_loadMoreListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LocaleKeys.working_hours.tr(),
          style: Theme.of(context).primaryTextTheme.displayLarge,
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const VerticalSpace(space: 40),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 24.w,
              ),
              child: Consumer(
                builder: (context, ref, child) {
                  final filters = ref.watch(logFilterProvider);

                  return Button(
                    label: LocaleKeys.filter.tr(),
                    onPressed: () {
                      showBottomModal(
                        context: context,
                        height: 300.h,
                        child: const WorkingHoursFilter(),
                        initCode: () {
                          ref
                              .read(modelLogFilterProvider.notifier)
                              .initialize(filters);
                        },
                      );
                    },
                  );
                },
              ),
            ),
            const VerticalSpace(),
            Consumer(
              builder: (_, ref, __) {
                final filters = ref.watch(logFilterProvider);
                return filters.activeFilters.isNotEmpty
                    ? Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                        ),
                        child: Wrap(
                          spacing: 10.w,
                          crossAxisAlignment: WrapCrossAlignment.start,
                          children: filters.activeFilters.map((e) {
                            return Chip(
                              label: Text(e),
                            );
                          }).toList(),
                        ),
                      )
                    : const SizedBox.shrink();
              },
            ),
            const VerticalSpace(),
            Expanded(
              child: RefreshIndicator(
                backgroundColor: Colors.white,
                onRefresh: () async {
                  ref.invalidate(timeLogsProvider);
                },
                child: ref.watch(timeLogsProvider).when(
                  data: (logs) {
                    if (logs.data.isEmpty) {
                      return NoDataPlaceholder(
                          text: LocaleKeys.no_working_hours.tr());
                    }
                    return ListView.separated(
                      controller: _scrollController,
                      itemCount: logs.data.length + (logs.hasNextPage ? 1 : 0),
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                      ),
                      itemBuilder: (context, index) {
                        if (index == logs.data.length) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        return DrivingHourCard(
                          log: logs.data[index],
                          onTap: () {
                            context.push(
                              Routes.logDetails,
                              extra: logs.data[index],
                            );
                          },
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const VerticalSpace(space: 20);
                      },
                    );
                  },
                  error: (error, stackTrace) {
                    return EmptyListPlaceholder(error);
                  },
                  loading: () {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
